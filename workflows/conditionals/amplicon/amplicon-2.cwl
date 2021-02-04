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
    filtered_fasta: File

    ssu_db: {type: File, secondaryFiles: [.mscluster] }
    lsu_db: {type: File, secondaryFiles: [.mscluster] }
    ssu_tax: string
    lsu_tax: string
    ssu_otus: string
    lsu_otus: string

    rfam_models: string[]
    rfam_model_clans: string

    ssu_label: string
    lsu_label: string
    5s_pattern: string
    5.8s_pattern: string

    unite_db: {type: File, secondaryFiles: [.mscluster] }
    unite_tax: string
    unite_otu_file: string
    unite_label: string
    itsonedb: {type: File, secondaryFiles: [.mscluster] }
    itsonedb_tax: string
    itsonedb_otu_file: string
    itsonedb_label: string

outputs:

  taxonomy-summary_folder:
    type: Directory?
    outputSource: suppress_tax/out_tax

  suppressed_upload:
    type: Directory?
    outputSource: suppress_tax/out_suppress

  sequence-categorisation_folder:
    type: Directory?
    outputSource: return_seq_dir/out

  rna-count:
    type: File
    outputSource: rna_prediction/LSU-SSU-count

  gz_files:  # fasta.gz, cmsearch.gz, deoverlapped.gz
    type: File[]
    outputSource: gzip_files/compressed_file

  ITS-length:
    type: File
    outputSource: suppress_tax/its_length

  optional_tax_file_flag:
    type: File?
    outputSource: no_tax_file_flag/created_file

steps:

# << Get RNA >>
  rna_prediction:
    run: ../../subworkflows/rna_prediction-sub-wf.cwl
    in:
      type: { default: 'raw'}
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
      - SSU_fasta
      - LSU_fasta
      - compressed_rnas
      - number_LSU_mapseq
      - number_SSU_mapseq

# << ITS >>
  ITS:
    run: ../../subworkflows/amplicon/ITS-wf.cwl
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
      - unite_folder
      - itsonedb_folder
      - number_ITS_seqs
      - masking_file

# gzip and chunk
  gzip_files:
    run: ../../../utils/pigz/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        - filtered_fasta
        - rna_prediction/cmsearch_result
        - rna_prediction/ncRNA
    out: [compressed_file]

# return ITS dir
  return_its_dir:
    when: $(inputs.unite_folder != null && inputs.itsonedb_folder != null)
    run: ../../../utils/return_directory.cwl
    in:
      unite_folder: ITS/unite_folder
      itsonedb_folder: ITS/itsonedb_folder
      dir_list:
        - ITS/unite_folder
        - ITS/itsonedb_folder
      dir_name: { default: 'its' }
    out: [out]

  gzip_SSU:
    run: ../../../utils/pigz/gzip.cwl
    in:
      uncompressed_file: rna_prediction/SSU_fasta
    out: [compressed_file]
  gzip_LSU:
    run: ../../../utils/pigz/gzip.cwl
    in:
      uncompressed_file: rna_prediction/LSU_fasta
    out: [compressed_file]

# suppress irrelevant rRNA/ITS tax folders
  suppress_tax:
    run: ../../../tools/mask-for-ITS/suppress_tax.cwl
    in:
      ssu_file: gzip_SSU/compressed_file
      lsu_file: gzip_LSU/compressed_file
      its_file: ITS/masking_file
      lsu_dir: rna_prediction/LSU_folder
      ssu_dir: rna_prediction/SSU_folder
      its_dir: return_its_dir/out
    out: [its_length, out_tax, out_suppress, out_fastas_tax]

# return sequence-categorisation:
  return_seq_dir:
    run: ../../../utils/return_directory.cwl
    when: $(inputs.rna != null || inputs.tax != null )
    in:
      rna: rna_prediction/compressed_rnas
      tax: suppress_tax/out_fastas_tax
      file_list:
        source:
          - rna_prediction/compressed_rnas
          - suppress_tax/out_fastas_tax
        linkMerge: merge_flattened
      dir_name: { default: 'sequence-categorisation' }
    out: [out]

# return no-tax if there is no taxonomy-summary folder
  no_tax_file_flag:
    when: $(inputs.folder == null )
    run: ../../../utils/touch_file.cwl
    in:
      folder: suppress_tax/out_tax
      filename: { default: no-tax }
    out: [ created_file ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"


