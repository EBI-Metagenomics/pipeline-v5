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

    qc_min_length: int
    stats_file_name: string

    ssu_db: {type: File, secondaryFiles: [.mscluster] }
    lsu_db: {type: File, secondaryFiles: [.mscluster] }
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
  hashsum_input:
    type: File
    outputSource: before-qc/hashsum_input

  gz_files:  # fasta.gz, cmsearch.gz, deoverlapped.gz
    type: File[]
    outputSource: after-qc/gz_files
  sequence-categorisation_folder:
    type: Directory
    outputSource: after-qc/sequence-categorisation_folder
  taxonomy-summary_folder:
    type: Directory
    outputSource: after-qc/taxonomy-summary_folder
  sequence-categorisation_masking:
    type: Directory
    outputSource: after-qc/sequence-categorisation_masking
  rna-count:
    type: File
    outputSource: after-qc/rna-count

steps:

  before-qc:
    run: conditionals/amplicon/amplicon-single-1.cwl
    in:
      single_reads: single_reads
      qc_min_length: qc_min_length
      stats_file_name: stats_file_name
    out:
      - filtered_fasta
      - qc-statistics
      - qc_summary
      - qc-status
      - hashsum_input

  after-qc:
    run: conditionals/amplicon/amplicon-2.cwl
    in:
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
      - gz_files
      - rna-count
      - sequence-categorisation_masking
      - taxonomy-summary_folder
      - sequence-categorisation_folder

