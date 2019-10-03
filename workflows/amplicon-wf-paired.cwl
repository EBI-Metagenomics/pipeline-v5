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
#      - $import: ../tools/Trimmomatic/trimmomatic-sliding_window.yaml

inputs:
    forward_reads: File
    reverse_reads: File

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
  gz_files:  # fasta.gz, cmsearch.gz, deoverlapped.gz
    type: File[]
    outputSource: amplicon-single/gz_files

  qc-statistics:
    type: Directory
    outputSource: amplicon-single/qc-statistics
  qc_summary:
    type: File
    outputSource: amplicon-single/qc_summary

  LSU_folder:
    type: Directory
    outputSource: amplicon-single/LSU_folder
  SSU_folder:
    type: Directory
    outputSource: amplicon-single/SSU_folder

  sequence-categorisation_folder:
    type: Directory
    outputSource: amplicon-single/sequence-categorisation_folder

  sequence-categorisation_masking:
    type: Directory
    outputSource: amplicon-single/sequence-categorisation_masking

  ITS_unite_results:
    type: Directory
    outputSource: amplicon-single/ITS_unite_results

  ITS_itsonedb_results:
    type: Directory
    outputSource: amplicon-single/ITS_itsonedb_results

steps:

# << SeqPrep >>
  overlap_reads:
    label: Paired-end overlapping reads are merged
    run: ../tools/SeqPrep/seqprep.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
    out: [ merged_reads, forward_unmerged_reads, reverse_unmerged_reads ]

# run amplicon-single-pipeline
  amplicon-single:
    run: amplicon-wf-single.cwl
    in:
      single_reads: overlap_reads/merged_reads
      forward_unmerged_reads: overlap_reads/forward_unmerged_reads
      reverse_unmerged_reads: overlap_reads/reverse_unmerged_reads

      qc_min_length: qc_min_length
      stats_file_name: stats_file_name

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
      - qc-statistics
      - qc_summary
      - LSU_folder
      - SSU_folder
      - sequence-categorisation_folder
      - sequence-categorisation_masking
      - ITS_unite_results
      - ITS_itsonedb_results