#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  ResourceRequirement:
      ramMin: 5000
      coresMin: 8
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
#  - class: SchemaDefRequirement
#    types:
#      - $import: ../tools/InterProScan/InterProScan-apps.yaml
#      - $import: ../tools/InterProScan/InterProScan-protein_formats.yaml

inputs:

  CGC_predicted_proteins: File
  chunk_size: int
  name_ips: string
  name_hmmscan: string

  HMMSCAN_gathering_bit_score: boolean
  HMMSCAN_omit_alignment: boolean
  HMMSCAN_name_database: string
  HMMSCAN_data: Directory

  EggNOG_db: File
  EggNOG_diamond_db: File
  EggNOG_data_dir: string

  InterProScan_databases: Directory
  InterProScan_applications: string[]  # ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
  InterProScan_outputFormat: string[]  # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?

outputs:
  hmmscan_result:
    type: File
    outputSource: combine_hmmscan/result
  ips_result:
    type: File
    outputSource: combine_ips/result
  eggnog_annotations:
    outputSource: eggnog/annotations
    type: File
  eggnog_orthologs:
    outputSource: eggnog/orthologs
    type: File

steps:

  # << Chunk faa file >>
  split_seqs:
    in:
      seqs: CGC_predicted_proteins
      chunk_size: chunk_size
    out: [ chunks ]
    run: ../../tools/chunks/fasta_chunker.cwl


  # << InterProScan >>
  interproscan:
    scatter: inputFile
    in:
      applications: InterProScan_applications
      inputFile: split_seqs/chunks
      outputFormat: InterProScan_outputFormat
      databases: InterProScan_databases
    out: [ i5Annotations ]
    run: ../../tools/InterProScan/InterProScan-v5-none_docker.cwl
    label: "InterProScan: protein sequence classifier"

  combine_ips:
    in:
      files: interproscan/i5Annotations
      outputFileName:
        source: CGC_predicted_proteins
        valueFrom: $(self.nameroot.split('_CDS')[0])
      postfix: name_ips
    out: [result]
    run: ../../utils/concatenate.cwl


  # << hmmscan >>
  hmmscan:
    scatter: seqfile
    in:
      seqfile: split_seqs/chunks
      gathering_bit_score: HMMSCAN_gathering_bit_score
      name_database: HMMSCAN_name_database
      data: HMMSCAN_data
      omit_alignment: HMMSCAN_omit_alignment
    out: [ output_table ]
    run: ../../tools/hmmscan/hmmscan-subwf.cwl
    label: "Analysis using profile HMM on db"

  combine_hmmscan:
    in:
      files: hmmscan/output_table
      outputFileName:
        source: CGC_predicted_proteins
        valueFrom: $(self.nameroot.split('_CDS')[0])
      postfix: name_hmmscan
    out: [result]
    run: ../../utils/concatenate.cwl

  # << EggNOG >>
  eggnog:
    run: ../../tools/Assembly/EggNOG/eggnog-subwf.cwl
    in:
      fasta_file: split_seqs/chunks
      db_diamond: EggNOG_diamond_db
      db: EggNOG_db
      data_dir: EggNOG_data_dir
      cpu: { default: 16 }
      file_acc:
        source: CGC_predicted_proteins
        valueFrom: $(self.nameroot)
    out: [ annotations, orthologs]