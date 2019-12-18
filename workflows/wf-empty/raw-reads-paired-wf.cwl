#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}
#  SchemaDefRequirement:
#    types:
#      - $import: ../tools/biom-convert/biom-convert-table.yaml

inputs:
    forward_reads: File
    reverse_reads: File

    qc_min_length: int

    ssu_db: {type: File, secondaryFiles: [.mscluster] }
    lsu_db: {type: File, secondaryFiles: [.mscluster] }
    ssu_tax: File
    lsu_tax: File
    ssu_otus: File
    lsu_otus: File

    rfam_models: File[]
    rfam_model_clans: File
    other_ncRNA_models: string[]
    #other_ncRNA_name: string

    ssu_label: string
    lsu_label: string
    5s_pattern: string
    5.8s_pattern: string

    # cgc
    CGC_config: File
    CGC_postfixes: string[]
    cgc_chunk_size: int

    # functional annotation
    fa_chunk_size: int
    func_ann_names_ips: string
    func_ann_names_hmmscan: string
    HMMSCAN_gathering_bit_score: boolean
    HMMSCAN_omit_alignment: boolean
    HMMSCAN_name_database: string
    HMMSCAN_data: Directory
    hmmscan_header: string
    EggNOG_db: File?
    EggNOG_diamond_db: File?
    EggNOG_data_dir: string?
    InterProScan_databases: Directory
    InterProScan_applications: string[]  # ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
    InterProScan_outputFormat: string[]  # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?
    ips_header: string

    # GO
    go_config: File

outputs:

  qc-statistics:
    type: Directory
    outputSource: single/qc-statistics
  qc_summary:
    type: File
    outputSource: single/qc_summary
  qc-status:
    type: File
    outputSource: single/qc-status

  LSU_folder:
    type: Directory
    outputSource: single/LSU_folder
  SSU_folder:
    type: Directory
    outputSource: single/SSU_folder

  sequence-categorisation_folder:
    type: Directory
    outputSource: single/sequence-categorisation_folder
  compressed_sequence_categorisation:
    type: Directory
    outputSource: single/compressed_sequence_categorisation
  ncrnas_folder:
    type: Directory
    outputSource: single/ncrnas_folder

  chunking_nucleotides:
    type: File[]
    outputSource: single/chunking_nucleotides
  chunking_proteins:
    type: File[]
    outputSource: single/chunking_proteins
  rna-count:
    type: File
    outputSource: single/rna-count

  motus_output:
    type: File
    outputSource: single/motus_output

  compressed_files:
    type: File[]
    outputSource: single/compressed_files

  functional_annotation_folder:
    type: Directory
    outputSource: single/functional_annotation_folder
  stats:
    outputSource: single/stats
    type: Directory

steps:

# << SeqPrep >>
  overlap_reads:
    label: Paired-end overlapping reads are merged
    run: ../tools/SeqPrep/seqprep.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
    out: [ merged_reads, forward_unmerged_reads, reverse_unmerged_reads ]

# << Run raw reads single pipeline >>
  single:
    label: run single pipeline on merged reads
    run: raw-reads-single-wf.cwl
    in:
      single_reads: overlap_reads/merged_reads
      forward_unmerged_reads: overlap_reads/forward_unmerged_reads
      reverse_unmerged_reads: overlap_reads/reverse_unmerged_reads

      qc_min_length: qc_min_length

      ssu_db: ssu_db
      lsu_db: lsu_db
      ssu_tax: ssu_tax
      lsu_tax: lsu_tax
      ssu_otus: ssu_otus
      lsu_otus: lsu_otus

      rfam_models: rfam_models
      rfam_model_clans: rfam_model_clans
      other_ncRNA_models: other_ncRNA_models

      ssu_label: ssu_label
      lsu_label: lsu_label
      5s_pattern: 5s_pattern
      5.8s_pattern: 5.8s_pattern

      # cgc
      CGC_config: CGC_config
      CGC_postfixes: CGC_postfixes
      cgc_chunk_size: cgc_chunk_size

      # functional annotation
      fa_chunk_size: fa_chunk_size
      func_ann_names_ips: func_ann_names_ips
      func_ann_names_hmmscan: func_ann_names_hmmscan
      HMMSCAN_gathering_bit_score: HMMSCAN_gathering_bit_score
      HMMSCAN_omit_alignment: HMMSCAN_omit_alignment
      HMMSCAN_name_database: HMMSCAN_name_database
      HMMSCAN_data: HMMSCAN_data
      hmmscan_header: hmmscan_header
      EggNOG_db: EggNOG_db
      EggNOG_diamond_db: EggNOG_diamond_db
      EggNOG_data_dir: EggNOG_data_dir
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
      ips_header: ips_header

      # GO
      go_config: go_config

    out:
      - qc-statistics
      - qc_summary
      - qc-status
      - LSU_folder
      - SSU_folder
      - sequence-categorisation_folder
      - compressed_sequence_categorisation
      - chunking_nucleotides
      - chunking_proteins
      - ncrnas_folder
      - rna-count
      - motus_output
      - compressed_files
      - functional_annotation_folder
      - stats




