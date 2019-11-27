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
    single_reads: File
    forward_reads: File?
    reverse_reads: File?

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
    outputSource: before-qc/qc-statistics
  qc_summary:
    type: File
    outputSource: before-qc/qc_summary
  qc-status:
    type: File
    outputSource: before-qc/qc-status

  LSU_folder:
    type: Directory
    outputSource: after-qc/LSU_folder
  SSU_folder:
    type: Directory
    outputSource: after-qc/SSU_folder

  sequence-categorisation_folder:
    type: Directory
    outputSource: after-qc/sequence-categorisation_folder
  sequence-categorisation_folder_two:
    type: Directory
    outputSource: after-qc/sequence-categorisation_folder_two
  ncrnas_folder:
    type: Directory
    outputSource: after-qc/ncrnas_folder

  rna-count:
    type: File
    outputSource: after-qc/rna-count

  motus_output:
    type: File
    outputSource: after-qc/motus_output

  compressed_files:
    type: File[]
    outputSource: after-qc/compressed_files

  functional_annotation_folder:
    type: Directory
    outputSource: after-qc/functional_annotation_folder
  stats:
    outputSource: after-qc/stats
    type: Directory

steps:

# << First part >>
  before-qc:
    run: raw-reads-single-1.cwl
    in:
      forward_unmerged_reads: forward_unmerged_reads
      reverse_unmerged_reads: reverse_unmerged_reads

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
      - motus_input
      - filtered_fasta

  after-qc:
    run: raw-reads-2.cwl
    in:
      motus_input: before-qc/motus_input
      filtered_fasta: before-qc/filtered_fasta
      forward_unmerged_reads: forward_unmerged_reads
      reverse_unmerged_reads: reverse_unmerged_reads

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
      - LSU_folder
      - SSU_folder
      - sequence-categorisation_folder
      - compressed_sequence_categorisation
      - ncrnas_folder
      - rna-count
      - compressed_files
      - functional_annotation_folder
      - stats
      - motus_output