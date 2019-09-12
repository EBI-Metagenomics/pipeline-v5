#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  - class: SubworkflowFeatureRequirement
  - class: ScatterFeatureRequirement
  - class: SchemaDefRequirement
#    types:
#      - $import: ../tools/InterProScan/InterProScan-apps.yaml
#      - $import: ../tools/InterProScan/InterProScan-protein_formats.yaml

inputs:
  sequences: File

  ncRNAs: File
  config: File
  pipeline_seq_type: string

  HMMSCAN_gathering_bit_score: boolean
  HMMSCAN_omit_alignment: boolean
  HMMSCAN_name_database: string
  HMMSCAN_data: Directory

  EggNOG_db: File
  EggNOG_diamond_db: File
  EggNOG_data_dir: string

#  InterProScan_databases: Directory
#  InterProScan_applications:   # ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
#  InterProScan_outputFormat:   # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?

outputs:

  CGC_predicted_proteins:
    outputSource: combined_gene_caller/predicted_proteins
    type: File
  CGC_predicted_seq:
    outputSource: combined_gene_caller/predicted_seq
    type: File

#  InterProScan_I5:
#    outputSource: interproscan/i5Annotations
#    type: File

  hmmscan_table:
    outputSource: hmmscan/output_table

#  eggnog_annotations:
#    outputSource: eggnog/output_annotations
#  eggnog_orthologs:
#    outputSource: eggnog/output_orthologs

steps:
  combined_gene_caller:
    run: ../tools/Combined_gene_caller/combined_gene_caller.cwl
    in:
      input_fasta: sequences
      seq_type: pipeline_seq_type
      maskfile: ncRNAs
      config: config
    out:
      - predicted_proteins
      - predicted_seq
      - gene_caller_out
      - stderr
      - stdout
    label: "predictions of FragGeneScan with faselector"

#  interproscan:
#    run: ../tools/InterProScan/InterProScan-v5.cwl
#    in:
#      applications: InterProScan_applications
#      inputFile: combined_gene_caller/predicted_proteins
#      outputFormat: InterProScan_outputFormat
#      databases: InterProScan_databases
#    out: [ i5Annotations ]
#    label: "InterProScan: protein sequence classifier"

  hmmscan:
    run: ../tools/hmmscan/hmmscan.cwl
    in:
      seqfile: combined_gene_caller/predicted_proteins
      gathering_bit_score: HMMSCAN_gathering_bit_score
      name_database: HMMSCAN_name_database
      data: HMMSCAN_data
      omit_alignment: HMMSCAN_omit_alignment
    out: [ output_table ]
    label: "Analysis using profile HMM on db"

#   eggnog:
#     run: ../tools/EggNOG/eggNOG/eggnog.cwl
#      in:
#        fasta_file: combined_gene_caller/predicted_proteins
#        db: EggNOG_db
#        db_diamond: EggNOG_diamond_db
#        data_dir: EggNOG_data_dir
#      out: [output_annotations, output_orthologs]
