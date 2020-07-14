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
  silva_ssu_taxonomy: string
  silva_lsu_taxonomy: string
  silva_ssu_otus: string
  silva_lsu_otus: string
  ncRNA_ribosomal_models: string[]
  ncRNA_ribosomal_model_clans: string
  pattern_SSU: string
  pattern_LSU: string
  pattern_5S: string
  pattern_5.8S: string


outputs:

  ncRNA:
    type: File
    outputSource: find_ribosomal_ncRNAs/deoverlapped_matches
  cmsearch_result:
    type: File
    outputSource: find_ribosomal_ncRNAs/concatenate_matches

  SSU_coords:  # for ITS
    type: File
    outputSource: extract_subunits_coords/SSU_seqs
  LSU_coords:  # for ITS
    type: File
    outputSource: extract_subunits_coords/LSU_seqs

  SSU_folder:  # for visualisation
    type: Directory
    outputSource: classify_SSUs/out_dir

  LSU_folder:  # for visualisation
    type: Directory
    outputSource: classify_LSUs/out_dir

  extract_sequences:
    type: File
    outputSource: extract_sequences/sequences

  LSU-SSU-count:
    type: File
    outputSource: extract_subunits_coords/counts

  SSU_fasta_file:
    type: File
    outputSource: classify_SSUs/fasta_output

  LSU_fasta_file:
    type: File
    outputSource: classify_LSUs/fasta_output

  compressed_SSU_fasta:
    type: File
    outputSource: classify_SSUs/compressed_fasta_output
  compressed_LSU_fasta:
    type: File
    outputSource: classify_LSUs/compressed_fasta_output
  compressed_rnas:
    type: File[]
    outputSource: gzip_files/compressed_file

steps:

  index_reads:
    run: ../../tools/RNA_prediction/easel/esl-sfetch-index.cwl
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
      targetFile: input_sequences
    out: [ cmsearch_matches, concatenate_matches, deoverlapped_matches ]

# extract coordinates for everything
  extract_coords:
    run: ../../tools/RNA_prediction/extract-coords/extract-coords_awk.cwl
    in:
      infernal_matches: find_ribosomal_ncRNAs/deoverlapped_matches
    out: [ matched_seqs_with_coords ]

# extract coords of SSU ans LSU for ITS
  extract_subunits_coords:
    run: ../../tools/RNA_prediction/get_subunits_coords/get_subunits_coords.cwl
    in:
      input: extract_coords/matched_seqs_with_coords
      pattern_SSU: pattern_SSU
      pattern_LSU: pattern_LSU
    out: [SSU_seqs, LSU_seqs, counts]

# extract sequences
  extract_sequences:
    run: ../../tools/RNA_prediction/easel/esl-sfetch-manyseqs.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      names_contain_subseq_coords: extract_coords/matched_seqs_with_coords
    out: [ sequences ]

# separate to SSU, LSU, 5S, 5.8S and models (6)
  extract_subunits:
    run: ../../tools/RNA_prediction/get_subunits_fasta/get_subunits.cwl
    in:
      input: extract_sequences/sequences
      pattern_SSU: pattern_SSU
      pattern_LSU: pattern_LSU
      pattern_5S: pattern_5S
      pattern_5.8S: pattern_5.8S
    out: [SSU_seqs, LSU_seqs, fastas]

# classify SSU
  classify_SSUs:
    run: classify-otu-visualise.cwl
    in:
      fasta: extract_subunits/SSU_seqs
      mapseq_ref: silva_ssu_database
      mapseq_taxonomy: silva_ssu_taxonomy
      otu_ref: silva_ssu_otus
      otu_label: pattern_SSU
      return_dirname: {default: 'SSU'}
      file_for_prefix: input_sequences
    out: [ out_dir, compressed_fasta_output, fasta_output ]

# classify LSU
  classify_LSUs:
    run: classify-otu-visualise.cwl
    in:
      fasta: extract_subunits/LSU_seqs
      mapseq_ref: silva_lsu_database
      mapseq_taxonomy: silva_lsu_taxonomy
      otu_ref: silva_lsu_otus
      otu_label: pattern_LSU
      return_dirname: {default: 'LSU'}
      file_for_prefix: input_sequences
    out: [ out_dir, compressed_fasta_output, fasta_output ]

# gzip and chunk sequence-categorisation
  gzip_files:
    run: ../../utils/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file: extract_subunits/fastas
    out: [compressed_file]
