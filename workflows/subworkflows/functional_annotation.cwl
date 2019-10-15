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

  names: string[]

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
  results:
    type: File
    outputSource: combine/result
    valueFrom: $( self.filter(file => !!file.basename.match(/^.*hmmscan.*$/)).pop() )

#  InterProScan_I5:
#    outputSource: interproscan/i5Annotations
#    type: File

#  hmmscan_table:
#    outputSource: hmmscan/output_table
#    type: File

#  eggnog_annotations:
#    outputSource: eggnog/output_annotations
#  eggnog_orthologs:
#    outputSource: eggnog/output_orthologs

steps:

  # << Chunk faa file >>
  split_seqs:
    in:
      seqs: CGC_predicted_proteins
      chunk_size: { default: 20 }  # 100000
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

  combine:
    scatter: [files, outputFileName]
    scatterMethod: dotproduct
    in:
      files:
        - interproscan/i5Annotations
        - hmmscan/output_table
      outputFileName: names
    out: [result]
    run: ../../tools/chunks/concatenate.cwl

  # << EggNOG >>
#  eggnog:
#    scatter: fasta_file
#      in:
#        fasta_file: split_seqs/chunks
#        db_diamond: EggNOG_diamond
#        db: EggNOG_db
#        data_dir: EggNOG_data_dir
#      out: [annotations, orthologs]
#    run: ../../tools/EggNOG/eggNOG/eggnog.cwl

#  combine_annotations:
#    run: ../../chunks/concatenate.cwl
#    in:
#      files: eggnog/annotations
#      outputFileName: { default: 'annotations_united' }
#    out: [ result ]

#  combine_orthologs:
#    run: ../../chunks/concatenate.cwl
#    in:
#      files: eggnog/orthologs
#      outputFileName: { default: 'orthologs_united' }
#    out: [ result ]
