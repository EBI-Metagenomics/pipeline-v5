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
    motus_input: File
    filtered_fasta: File

    single_reads: File?
    forward_unmerged_reads: File?
    reverse_unmerged_reads: File?

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
  motus_output:
    type: File
    outputSource: motus_taxonomy/motus

  LSU_folder:
    type: Directory
    outputSource: classify/LSU_folder
  SSU_folder:
    type: Directory
    outputSource: classify/SSU_folder

  sequence-categorisation_folder:
    type: Directory
    outputSource: classify/sequence-categorisation

  ncrnas_folder:
    type: Directory
    outputSource: other_ncrnas/ncrnas

  rna-count:
    type: File
    outputSource: classify/LSU-SSU-count


steps:
# << mOTUs2 >>
  motus_taxonomy:
    run: ../../subworkflows/raw_reads/mOTUs-workflow.cwl
    in:
      reads: motus_input
    out: [ motus ]

# << Get RNA >>
  classify:
    run: ../../subworkflows/rna_prediction-sub-wf.cwl
    in:
      input_sequences: filtered_fasta
      silva_ssu_database: ssu_db
      silva_lsu_database: lsu_db
      silva_ssu_taxonomy: ssu_tax
      silva_lsu_taxonomy: lsu_tax
      silva_ssu_otus: ssu_otus
      silva_lsu_otus: lsu_otus
      ncRNA_ribosomal_models: rfam_models
      ncRNA_ribosomal_model_clans: rfam_model_clans
      pattern_SSU: ssu_label
      pattern_LSU: lsu_label
      pattern_5S: 5s_pattern
      pattern_5.8S: 5.8s_pattern
    out:
      - ncRNA
      - cmsearch_result
      - LSU-SSU-count
      - SSU_folder
      - LSU_folder
      - sequence-categorisation
      - LSU_fasta_file
      - SSU_fasta_file

# << other ncrnas >>
  other_ncrnas:
    run: ../../subworkflows/other_ncrnas.cwl
    in:
     input_sequences: filtered_fasta
     cmsearch_file: classify/ncRNA
     other_ncRNA_ribosomal_models: other_ncRNA_models
     name_string: { default: 'other_ncrna' }
    out: [ ncrnas ]