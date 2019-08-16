#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  input_sequences: File
  silva_ssu_database: {type: File, secondaryFiles: [.mscluster] }
  silva_lsu_database: {type: File, secondaryFiles: [.mscluster] }
  silva_ssu_taxonomy: File
  silva_lsu_taxonomy: File
  silva_ssu_otus: File
  silva_lsu_otus: File
  ncRNA_ribosomal_models: File
  ncRNA_ribosomal_model_clans: File
  otu_ssu_label:
    type: string
  otu_lsu_label:
    type: string

outputs:
  ncRNAs:
    type: File
    outputSource: find_ribosomal_ncRNAs/deoverlapped_matches

  SSU_fasta:
    type: File
    outputSource: extract_SSUs/sequences

  LSU_fasta:
    type: File
    outputSource: extract_LSUs/sequences

  SSU_classifications:
    type: File
    outputSource: classify_SSUs/mapseq_classifications

  SSU_otu_tsv:
    type: File
    outputSource: classify_SSUs/otu_tsv

  SSU_krona_image:
    type: File
    outputSource: classify_SSUs/krona_image

  LSU_classifications:
    type: File
    outputSource: classify_LSUs/mapseq_classifications

  LSU_otu_tsv:
    type: File
    outputSource: classify_LSUs/otu_tsv

  LSU_krona_image:
    type: File
    outputSource: classify_LSUs/krona_image


steps:

#find SSU and LSU and get coords

  find_ribosomal_ncRNAs:
    run: cmsearch-multimodel-wf.cwl
    in:
      query_sequences: input_sequences
      covariance_models: ncRNA_ribosomal_models
      clan_info: ncRNA_ribosomal_model_clans
    out: [ deoverlapped_matches ]

  index_reads:
    run: ../tools/easel/esl-sfetch-index.cwl
    in:
      sequences: input_sequences
    out: [ sequences_with_index ]

  get_SSU_coords:
    run: ../tools/RNA_prediction/SSU-from-tablehits.cwl
    in:
      table_hits: find_ribosomal_ncRNAs/deoverlapped_matches
    out: [ SSU_coordinates ]

  get_LSU_coords:
    run: ../tools/RNA_prediction/LSU-from-tablehits.cwl
    in:
      table_hits: find_ribosomal_ncRNAs/deoverlapped_matches
    out: [ LSU_coordinates ]

#extract LSU and SSU
#mapseq SILVA
#convert to OTU
#krona visualisation

  extract_SSUs:
      run: ../tools/easel/esl-sfetch-manyseqs.cwl
      in:
        indexed_sequences: index_reads/sequences_with_index
        names_contain_subseq_coords: get_SSU_coords/SSU_coordinates
      out: [ sequences ]

  classify_SSUs:
    run: classify-otu-visualise.cwl
    in:
      fasta: extract_SSUs/sequences
      mapseq_ref: silva_ssu_database
      mapseq_taxonomy: silva_ssu_taxonomy
      otu_ref: silva_ssu_otus
      otu_label: otu_ssu_label
    out: [ krona_image, mapseq_classifications, otu_tsv, otu_txt ]

  extract_LSUs:
      run: ../tools/easel/esl-sfetch-manyseqs.cwl
      in:
        indexed_sequences: index_reads/sequences_with_index
        names_contain_subseq_coords: get_LSU_coords/LSU_coordinates
      out: [ sequences ]

  classify_LSUs:
    run: classify-otu-visualise.cwl
    in:
      fasta: extract_LSUs/sequences
      mapseq_ref: silva_lsu_database
      mapseq_taxonomy: silva_lsu_taxonomy
      otu_ref: silva_lsu_otus
      otu_label: otu_lsu_label
    out: [ krona_image, mapseq_classifications, otu_tsv, otu_txt ]

