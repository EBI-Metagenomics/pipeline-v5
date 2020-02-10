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
    filtered_fasta: File

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

  sequence-categorisation_folder:
    type: Directory
    outputSource: classify/sequence-categorisation

  sequence-categorisation_folder_two:
    type: Directory
    outputSource: classify/sequence-categorisation_two

  sequence-categorisation_masking:
    type: Directory
    outputSource: ITS/masking_file

  taxonomy-summary_folder:
    type: Directory
    outputSource: return_directory/out

  rna-count:
    type: File
    outputSource: classify/LSU-SSU-count

  gz_files:  # fasta.gz, cmsearch.gz, deoverlapped.gz
    type: File[]
    outputSource: gzip_files/compressed_file

steps:

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
      - sequence-categorisation_two
      - SSU_coords
      - LSU_coords

# << ITS >>
  ITS:
    run: ../../subworkflows/ITS/ITS-wf.cwl
    in:
      query_sequences: filtered_fasta
      LSU_coordinates: classify/LSU_coords
      SSU_coordinates: classify/SSU_coords
      unite_database: unite_db
      unite_taxonomy: unite_tax
      unite_otus: unite_otu_file
      itsone_database: itsonedb
      itsone_taxonomy: itsonedb_tax
      itsone_otus: itsonedb_otu_file
      otu_unite_label: unite_label
      otu_itsone_label: itsonedb_label
    out:
      - masking_file
      - unite_folder
      - itsonedb_folder

# gzip and chunk
  gzip_files:
    run: ../../../utils/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        - filtered_fasta
        - classify/cmsearch_result
        - classify/ncRNA
    out: [compressed_file]

# return taxonomy-summary
  return_directory:
    run: ../../../utils/return_directory.cwl
    in:
      dir_list:
        - classify/SSU_folder
        - classify/LSU_folder
        - ITS/unite_folder
        - ITS/itsonedb_folder
      dir_name: { default: 'taxonomy-summary' }
    out: [out]