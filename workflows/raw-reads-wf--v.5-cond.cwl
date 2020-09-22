#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2.0-dev4

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

    # cgc
    CGC_config: [string?, File?]
    CGC_postfixes: string[]
    cgc_chunk_size: int

    # functional annotation
    protein_chunk_size_hmm: int
    protein_chunk_size_IPS: int
    func_ann_names_ips: string
    func_ann_names_hmmer: string
    HMM_gathering_bit_score: boolean
    HMM_omit_alignment: boolean
    HMM_name_database: string
    hmmsearch_header: string
    EggNOG_db: [string?, File?]
    EggNOG_diamond_db: [string?, File?]
    EggNOG_data_dir: string?
    InterProScan_databases: string
    InterProScan_applications: string[]  # ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
    InterProScan_outputFormat: string[]  # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?
    ips_header: string
    ko_file: string

    # GO
    go_config: [string?, File?]

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

  sequence-categorisation_folder:
    type: Directory?
    outputSource: after-qc/sequence_categorisation_folder
  taxonomy-summary_folder:
    type: Directory?
    outputSource: after-qc/taxonomy-summary_folder
  rna-count:
    type: File?
    outputSource: after-qc/rna-count

  motus_output:
    type: File?
    outputSource: after-qc/motus_output

  compressed_files:
    type: File[]
    outputSource: after-qc/compressed_files
    pickValue: all_non_null

  functional_annotation_folder:
    type: Directory?
    outputSource: after-qc/functional_annotation_folder
  stats:
    outputSource: after-qc/stats
    type: Directory?

  chunking_nucleotides:
    type: File[]?
    outputSource: after-qc/chunking_nucleotides
  chunking_proteins:
    type: File[]?
    outputSource: after-qc/chunking_proteins

  completed_flag_file:
    type: File?
    outputSource: touch_file_flag/created_file

steps:

# << First part >>
  before-qc:
    run: conditionals/raw-reads/raw-reads-1.cwl
    in:
      single_reads: single_reads
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      qc_min_length: qc_min_length
    out:
      - qc-statistics
      - qc_summary
      - qc-status
      - motus_input
      - filtered_fasta
      - input_files_hashsum_paired
      - input_files_hashsum_single

  after-qc:
    run: conditionals/raw-reads/raw-reads-2.cwl
    when: $(inputs.status.basename == 'QC-PASSED')
    in:
      status: before-qc/qc-status
      motus_input: before-qc/motus_input
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
      CGC_postfixes: CGC_postfixes
      cgc_chunk_size: cgc_chunk_size
      protein_chunk_size_hmm: protein_chunk_size_hmm
      protein_chunk_size_IPS: protein_chunk_size_IPS
      func_ann_names_ips: func_ann_names_ips
      func_ann_names_hmmer: func_ann_names_hmmer
      HMM_gathering_bit_score: HMM_gathering_bit_score
      HMM_omit_alignment: HMM_omit_alignment
      HMM_name_database: HMM_name_database
      hmmsearch_header: hmmsearch_header
      EggNOG_db: EggNOG_db
      EggNOG_diamond_db: EggNOG_diamond_db
      EggNOG_data_dir: EggNOG_data_dir
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
      ips_header: ips_header
      go_config: go_config
      ko_file: ko_file
    out:
      - motus_output
      - sequence_categorisation_folder
      - taxonomy-summary_folder
      - rna-count
      - compressed_files
      - functional_annotation_folder
      - stats
      - chunking_nucleotides
      - chunking_proteins

  touch_file_flag:
    when: $(inputs.count != undefined || inputs.status.basename == "QC-FAILED")
    run: ../utils/touch_file.cwl
    in:
      status: before-qc/qc-status
      count: after-qc/rna-count
      filename: { default: 'wf-completed' }
    out: [ created_file ]


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"
