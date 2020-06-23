#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2.0-dev2

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
    single_reads: File?
    forward_reads: File?
    reverse_reads: File?

    qc_min_length: int
    stats_file_name: string

    ssu_db:
      type: File
      secondaryFiles: [ .mscluster ]
    lsu_db:
      type: File
      secondaryFiles: [ .mscluster ]
    ssu_tax: File
    lsu_tax: File
    ssu_otus: File
    lsu_otus: File

    rfam_models: File[]
    rfam_model_clans: File

    ssu_label: string
    lsu_label: string
    5s_pattern: string
    5.8s_pattern: string

    unite_db: {type: File, secondaryFiles: [.mscluster] }
    unite_tax: File
    unite_otu_file: File
    unite_label: string
    itsonedb: {type: File, secondaryFiles: [.mscluster] }
    itsonedb_tax: File
    itsonedb_otu_file: File
    itsonedb_label: string

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
  hashsum_paired:
    type: File[]?
    outputSource: before-qc/input_files_hashsum_paired
  hashsum_single:
    type: File?
    outputSource: before-qc/input_files_hashsum_single

  gz_files:
    type: File[]
    outputSource: after-qc/gz_files
    pickValue: all_non_null
  sequence-categorisation_folder:
    type: Directory
    outputSource: after-qc/sequence-categorisation_folder
  taxonomy-summary_folder:
    type: Directory
    outputSource: after-qc/taxonomy-summary_folder
  rna-count:
    type: File
    outputSource: after-qc/rna-count
  ITS-length:
    type: File
    outputSource: after-qc/ITS-length
  suppressed_upload:
    type: Directory
    outputSource: after-qc/suppressed_upload

  completed_flag_file:
    type: File
    outputSource: touch_file_flag/created_file

steps:

  before-qc:
    run: conditionals/amplicon/amplicon-1.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      single_reads: single_reads
      qc_min_length: qc_min_length
      stats_file_name: stats_file_name
    out:
      - filtered_fasta
      - qc-statistics
      - qc_summary
      - qc-status
      - input_files_hashsum_paired
      - input_files_hashsum_single

  after-qc:
    run: conditionals/amplicon/amplicon-2.cwl
    when: $(inputs.status.basename == 'QC-PASSED')
    in:
      status: before-qc/qc-status
      filtered_fasta: before-qc/filtered_fasta
      ssu_db: ssu_db
      lsu_db: lsu_db
      ssu_tax: ssu_tax
      lsu_tax: lsu_tax
      ssu_otus: ssu_otus
      lsu_otus: lsu_otus
      rfam_models: rfam_models
      rfam_model_clans: rfam_model_clans
      ssu_label: ssu_label
      lsu_label: lsu_label
      5s_pattern: 5s_pattern
      5.8s_pattern: 5.8s_pattern
      unite_db: unite_db
      unite_tax: unite_tax
      unite_otu_file: unite_otu_file
      unite_label: unite_label
      itsonedb: itsonedb
      itsonedb_tax: itsonedb_tax
      itsonedb_otu_file: itsonedb_otu_file
      itsonedb_label: itsonedb_label
    out:
      - taxonomy-summary_folder
      - suppressed_upload
      - sequence-categorisation_folder
      - rna-count
      - gz_files
      - ITS-length

  touch_file_flag:
    when: $(inputs.count != undefined || inputs.status.basename == "QC-FAILED")
    run: ../utils/touch_file.cwl
    in:
      status: before-qc/qc-status
      count: after-qc/rna-count
      filename: { default: 'wf-completed' }
    out: [ created_file ]