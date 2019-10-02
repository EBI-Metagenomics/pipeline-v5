#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}
  ResourceRequirement:
    ramMin: 25000
    ramMax: 25000
    coresMin: 2
#  SchemaDefRequirement:
#    types:
#      - $import: ../tools/biom-convert/biom-convert-table.yaml

inputs:
  input_sequences: File
  silva_ssu_database:
    type: File
    secondaryFiles: [.mscluster]
  silva_lsu_database:
    type: File
    secondaryFiles: [.mscluster]
  silva_ssu_taxonomy: File
  silva_lsu_taxonomy: File
  silva_ssu_otus: File
  silva_lsu_otus: File
  ncRNA_ribosomal_models: File[]
  ncRNA_ribosomal_model_clans: File
  pattern_SSU: string
  pattern_LSU: string
  pattern_5S: string
  pattern_5.8S: string


outputs:
  cmsearch_tblout:
    type: File
    outputSource: find_ribosomal_ncRNAs/concatenate_matches
  ncRNAs:
    type: File
    outputSource: find_ribosomal_ncRNAs/deoverlapped_matches
  SSU_fasta:
    type: File
    outputSource: extract_subunits/SSU_seqs
  LSU_fasta:
    type: File
    outputSource: extract_subunits/LSU_seqs
  5S_fasta:
    type: File?
    outputSource: extract_subunits/5S_seqs
  5_8S_fasta:
    type: File?
    outputSource: extract_subunits/5_8S_seqs

  SSU_coords:
    type: File
    outputSource: extract_subunits_coords/SSU_seqs
  LSU_coords:
    type: File
    outputSource: extract_subunits_coords/LSU_seqs

  sequences_esl:
    type: File
    outputSource: extract_sequences/sequences

steps:

  index_reads:
    run: ../tools/easel/esl-sfetch-index.cwl
    in:
      sequences: input_sequences
    out: [ sequences_with_index ]

# cmsearch -> concatinate -> deoverlap
  find_ribosomal_ncRNAs:
    run: cmsearch-multimodel-wf.cwl
    in:
      query_sequences: input_sequences
      covariance_models: ncRNA_ribosomal_models
      clan_info: ncRNA_ribosomal_model_clans
      catOutputFileName: { default: "result_cat" }
    out: [ cmsearch_matches, concatenate_matches, deoverlapped_matches ]

# extract coordinates for everything
  extract_coords:
    run: ../tools/RNA_prediction/extract-coords_awk.cwl
    in:
      infernal_matches: find_ribosomal_ncRNAs/deoverlapped_matches
    out: [ matched_seqs_with_coords ]

# extract coords of SSU ans LSU for ITS
  extract_subunits_coords:
    run: ../tools/RNA_prediction/get_subunits.cwl
    in:
      input: extract_coords/matched_seqs_with_coords
      pattern_SSU: pattern_SSU
      pattern_LSU: pattern_LSU
      mode: { default: 'coords' }
    out: [SSU_seqs, LSU_seqs]

# extract sequences
  extract_sequences:
    run: ../tools/easel/esl-sfetch-manyseqs.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      names_contain_subseq_coords: extract_coords/matched_seqs_with_coords
    out: [ sequences ]

# separate to SSU, LSU and 5.8S
  extract_subunits:
    run: ../tools/RNA_prediction/get_subunits.cwl
    in:
      input: extract_sequences/sequences
      pattern_SSU: pattern_SSU
      pattern_LSU: pattern_LSU
      pattern_5S: pattern_5S
      pattern_5.8S: pattern_5.8S
      mode: { default: 'fasta' }
    out: [SSU_seqs, LSU_seqs, 5S_seqs, 5_8S_seqs]