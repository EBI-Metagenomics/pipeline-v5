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

  taxonomy-summary_folder:
    type: Directory
    outputSource: return_tax_dir/out

  sequence-categorisation_folder:
    type: Directory
    outputSource: return_seq_dir/out

  rna-count:
    type: File
    outputSource: rna_prediction/LSU-SSU-count

  gz_files:  # fasta.gz, cmsearch.gz, deoverlapped.gz
    type: File[]
    outputSource: gzip_files/compressed_file

  ITS-length:
    type: File
    outputSource: suppress_tax/stdout

steps:

# << Get RNA >>
  rna_prediction:
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
      - SSU_coords
      - LSU_coords
      - compressed_SSU_fasta
      - compressed_LSU_fasta
      - compressed_rnas

# << ITS >>
  ITS:
    run: ../../subworkflows/ITS/ITS-wf.cwl
    in:
      query_sequences: filtered_fasta
      LSU_coordinates: rna_prediction/LSU_coords
      SSU_coordinates: rna_prediction/SSU_coords
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
        - rna_prediction/cmsearch_result
        - rna_prediction/ncRNA
    out: [compressed_file]

# return ITS dir
  return_its_dir:
    run: ../../../utils/return_directory.cwl
    in:
      dir_list:
        - ITS/unite_folder
        - ITS/itsonedb_folder
      dir_name: { default: 'its' }
    out: [out]

# suppress irrelevant rRNA/ITS tax folders
  suppress_tax:
    run: ../../../tools/mask-for-ITS/suppress_tax.cwl
    in:
      ssu_file: rna_prediction/compressed_SSU_fasta
      lsu_file: rna_prediction/compressed_LSU_fasta
      its_file: ITS/masking_file
      lsu_dir: rna_prediction/LSU_folder
      ssu_dir: rna_prediction/SSU_folder
      its_dir: return_its_dir/out
    out: [stdout, out_lsu, out_ssu, out_its, out_fasta]

# return sequence-categorisation:
  return_seq_dir:
    run: ../../../utils/return_directory.cwl
    in:
      file_list:
        source:
          - rna_prediction/compressed_SSU_fasta
          - rna_prediction/compressed_LSU_fasta
          - rna_prediction/compressed_rnas
          - suppress_tax/out_fasta
        linkMerge: merge_flattened
      dir_name: { default: 'sequence-categorisation' }
    out: [out]

# return taxonomy-summary
  return_tax_dir:
    run: ../../../utils/return_directory.cwl
    in:
      dir_list:
        - suppress_tax/out_lsu
        - suppress_tax/out_ssu
        - suppress_tax/out_its
      dir_name: { default: 'taxonomy-summary' }
    out: [out]
