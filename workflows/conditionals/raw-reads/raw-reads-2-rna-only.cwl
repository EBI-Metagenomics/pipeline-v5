#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2

requirements:
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:

    filtered_fasta: File

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
      - SSU_fasta
      - LSU_fasta
      - compressed_rnas
      - number_LSU_mapseq
      - number_SSU_mapseq

# add no-tax file-flag if there are no lsu and ssu seqs
  no_tax_file_flag:
    when: $(inputs.count_lsu < 3 && inputs.count_ssu < 3)
    run: ../../../utils/touch_file.cwl
    in:
      count_lsu: rna_prediction/number_LSU_mapseq
      count_ssu: rna_prediction/number_SSU_mapseq
      filename: { default: no-tax}
    out: [ created_file ]


# << other ncrnas >>
  other_ncrnas:
    run: ../../subworkflows/other_ncrnas.cwl
    in:
     input_sequences: filtered_fasta
     cmsearch_file: rna_prediction/ncRNA
     other_ncRNA_ribosomal_models: other_ncRNA_models
     name_string: { default: 'other_ncrna' }
    out: [ ncrnas ]

# << ------------------ FINAL STEPS -------------------------- >>
# gzip
  compression:
    run: ../../../utils/pigz/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        source:
          - rna_prediction/ncRNA # "cmsearch.all.deoverlapped"
          - rna_prediction/cmsearch_result # "cmsearch.all"
        linkMerge: merge_flattened
    out: [compressed_file]

# << --------- TAXONOMY FORMATTING AND CHUNKING ------ >>

# << chunking >>
  fasta_chunking:
    run: ../../../utils/result-file-chunker/result_chunker_subwf.cwl
    in:
      input_files:
        source: [ filtered_fasta ]
        linkMerge: merge_flattened
      format: {default: fasta}
      type_fasta: {default: n}
    out: [ chunked_by_size_files ]
  tax_chunking:
    run: ../../../utils/result-file-chunker/result_chunker_subwf.cwl
    in:
      input_files:
        - rna_prediction/LSU_fasta
        - rna_prediction/SSU_fasta
      format: {default: fasta}
      type_fasta: {default: n}
    out: [ chunked_by_size_files ] # "LSU, SSU"

# << move chunked files >>
  move_to_seq_cat_folder:  # LSU and SSU
    run: ../../../utils/return_directory/return_directory.cwl
    in:
      file_list:
        source:
          - tax_chunking/chunked_by_size_files
          - rna_prediction/compressed_rnas
          - other_ncrnas/ncrnas
        linkMerge: merge_flattened
      dir_name: { default: 'sequence-categorisation' }
    out: [ out ]

# return taxonomy summary dir
  return_tax_dir:
    run: ../../../utils/return_directory/return_directory.cwl
    in:
      dir_list:
        - rna_prediction/SSU_folder
        - rna_prediction/LSU_folder
      dir_name: { default: 'taxonomy-summary' }
    out: [out]

outputs:
  sequence_categorisation_folder:
    type: Directory
    outputSource: move_to_seq_cat_folder/out  
  taxonomy-summary_folder:
    type: Directory
    outputSource: return_tax_dir/out

  chunking_nucleotides:
    type: File[]
    outputSource: fasta_chunking/chunked_by_size_files
  rna-count:
    type: File
    outputSource: rna_prediction/LSU-SSU-count

  compressed_files:
    type: File[]
    outputSource: compression/compressed_file

  optional_tax_file_flag:
    type: File?
    outputSource: no_tax_file_flag/created_file

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
