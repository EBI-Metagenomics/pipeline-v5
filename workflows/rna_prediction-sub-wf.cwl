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


outputs:
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
    type: File
    outputSource: extract_subunits/5S_seqs

  SSU_classifications:
    type: File
    outputSource: classify_SSUs/mapseq_classifications
  SSU_otu_txt:
    type: File
    outputSource: classify_SSUs/krona_txt
  SSU_otu_tsv:
    type: File
    outputSource: classify_SSUs/krona_tsv
  SSU_krona_image:
    type: File
    outputSource: classify_SSUs/krona_image

  LSU_classifications:
    type: File
    outputSource: classify_LSUs/mapseq_classifications
  LSU_otu_txt:
    type: File
    outputSource: classify_LSUs/krona_txt
  LSU_otu_tsv:
    type: File
    outputSource: classify_LSUs/krona_tsv
  LSU_krona_image:
    type: File
    outputSource: classify_LSUs/krona_image

#  ssu_hdf5_classifications:
#    type: File
#    outputSource: ssu_convert_otu_counts_to_hdf5/result

#  ssu_json_classifications:
#    type: File
#    outputSource: ssu_convert_otu_counts_to_json/result

#  lsu_hdf5_classifications:
#    type: File
#    outputSource: lsu_convert_otu_counts_to_hdf5/result

#  lsu_json_classifications:
#    type: File
#    outputSource: lsu_convert_otu_counts_to_json/result

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
      mode: { default: 'fasta' }
    out: [SSU_seqs, LSU_seqs, 5S_seqs]

# classify SSU
  classify_SSUs:
    run: classify-otu-visualise.cwl
    in:
      fasta: extract_subunits/SSU_seqs
      mapseq_ref: silva_ssu_database
      mapseq_taxonomy: silva_ssu_taxonomy
      otu_ref: silva_ssu_otus
      otu_label: pattern_SSU
    out: [ mapseq_classifications, krona_tsv, krona_txt, krona_image ]

# classify LSU
  classify_LSUs:
    run: classify-otu-visualise.cwl
    in:
      fasta: extract_subunits/LSU_seqs
      mapseq_ref: silva_lsu_database
      mapseq_taxonomy: silva_lsu_taxonomy
      otu_ref: silva_lsu_otus
      otu_label: pattern_LSU
    out: [ mapseq_classifications, krona_tsv, krona_txt, krona_image ]

#convert biom to hdf5 and json formats

#  ssu_convert_otu_counts_to_hdf5:
#    run: ../tools/biom-convert/biom-convert.cwl
#    in:
#       biom: classify_SSUs/krona_tsv
#       hdf5: { default: true }
#       table_type: { default: 'OTU table' }
#    out: [ result ]

#  ssu_convert_otu_counts_to_json:
#    run: ../tools/biom-convert/biom-convert.cwl
#    in:
#       biom: classify_SSUs/krona_tsv
#       json: { default: true }
#       table_type: { default: 'OTU table' }
#    out: [ result ]

#  lsu_convert_otu_counts_to_hdf5:
#    run: ../tools/biom-convert/biom-convert.cwl
#    in:
#       biom: classify_LSUs/krona_tsv
#       hdf5: { default: true }
#       table_type: { default: 'OTU table' }
#    out: [ result ]

#  lsu_convert_otu_counts_to_json:
#    run: ../tools/biom-convert/biom-convert.cwl
#    in:
#       biom: classify_LSUs/krona_tsv
#       json: { default: true }
#       table_type: { default: 'OTU table' }
#    out: [ result ]