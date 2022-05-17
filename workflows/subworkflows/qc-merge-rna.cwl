#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

doc: |
  This workflow will run a QC on the reads and then ti will
  do the RNA annotation of them.

inputs:
    run_qc:
      type: boolean
      default: true
    single_reads: File?
    forward_reads: File?
    reverse_reads: File?

    qc_min_length: int

    ssu_db: {type: File, secondaryFiles: [.mscluster] }
    lsu_db: {type: File, secondaryFiles: [.mscluster] }
    ssu_tax: [string, File]
    lsu_tax: [string, File]
    ssu_otus: [string, File]
    lsu_otus: [string, File]

    rfam_models:
      type:
        - type: array
          items: [string, File]
    rfam_model_clans: [string, File]
    other_ncRNA_models: string[]

    ssu_label: string
    lsu_label: string
    5s_pattern: string
    5.8s_pattern: string

outputs:

  qc-statistics:
    type: Directory?
    outputSource: before-qc/qc-statistics
  qc_summary:
    type: File?
    outputSource: before-qc/qc_summary
  qc-status:
    type: File?
    outputSource: before-qc/qc-status
  hashsum_paired:
    type: File[]?
    outputSource: before-qc/input_files_hashsum_paired
  hashsum_single:
    type: File?
    outputSource: before-qc/input_files_hashsum_single
  fastp_filtering_json_report:
    type: File?
    outputSource: before-qc/fastp_filtering_json


  sequence-categorisation_folder:
    type: Directory?
    outputSource: after-qc/sequence_categorisation_folder
  taxonomy-summary_folder:
    type: Directory?
    outputSource: after-qc/taxonomy-summary_folder
  rna-count:
    type: File?
    outputSource: after-qc/rna-count

  chunking_nucleotides:
    type: File[]?
    outputSource: after-qc/chunking_nucleotides

  no_tax_flag_file:
    type: File?
    outputSource: after-qc/optional_tax_file_flag

steps:

# << First part >>
  before-qc:
    run: ../conditionals/raw-reads/raw-reads-1-qc-cond.cwl
    in:
      single_reads: single_reads
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      qc_min_length: qc_min_length
      run_qc: run_qc
    out:
      - qc-statistics
      - qc_summary
      - qc-status
      - filtered_fasta
      - input_files_hashsum_paired
      - input_files_hashsum_single
      - fastp_filtering_json

  after-qc:
    run: ../conditionals/raw-reads/raw-reads-2-rna-only.cwl
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
      other_ncRNA_models: other_ncRNA_models
      ssu_label: ssu_label
      lsu_label: lsu_label
      5s_pattern: 5s_pattern
      5.8s_pattern: 5.8s_pattern
    out:
      - sequence_categorisation_folder
      - taxonomy-summary_folder
      - rna-count
      - compressed_files
      - chunking_nucleotides
      - optional_tax_file_flag

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
