class: Workflow
cwlVersion: v1.0

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  sequencing_run_id: string  # convert_classifications_to_otu_counts
  input_sequences:
    type: File
    format: edam:format_1929  # FASTA
  ncRNA_ribosomal_models: File[]  # find_ribosomal_ncRNAs
  ncRNA_ribosomal_model_clans: File  # find_ribosomal_ncRNAs

  mapseq_ref:  # classify_SSUs
    type: File
    format: edam:format_1929  # FASTA
    secondaryFiles: .mscluster
  mapseq_taxonomy: File  # classify_SSUs


outputs:
  #Repeat extraction for LSU
  LSU_sequences:
    type: File
    outputSource: extract_LSUs/sequences

  #Taxonomic analysis step
  SSU_sequences:
    type: File
    outputSource: extract_SSUs/sequences

  ssu_classifications:
    type: File
    outputSource: classify_SSUs/classifications

  #Taxonomic visualisation step
  ssu_otu_visualization:
    type: File
    outputSource: visualize_otu_counts/otu_visualization

  ssu_otu_counts_hdf5:
    type: File
    outputSource: convert_otu_counts_to_hdf5/result

  ssu_otu_counts_json:
    type: File
    outputSource: convert_otu_counts_to_json/result


steps:
  index_reads:
    run: ../tools/RNA_prediction/esl-sfetch-index.cwl
    in:
      sequences: input_sequences
    out: [ sequences_with_index ]

  find_ribosomal_ncRNAs:
    run: cmsearch-multimodel-wf.cwl
    in:
      query_sequences: input_sequences
      covariance_models: ncRNA_ribosomal_models
      clan_info: ncRNA_ribosomal_model_clans
    out: [ matches ]

  # << LSU >>
  get_LSU_coords:
    run: ../tools/RNA_prediction/LSU-from-tablehits.cwl
    in:
      table_hits: find_ribosomal_ncRNAs/matches
    out: [ LSU_coordinates ]

  extract_LSUs:
    run: ../tools/RNA_prediction/esl-sfetch-manyseqs.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      names: get_LSU_coords/LSU_coordinates
      names_contain_subseq_coords: { default: true }
    out: [ sequences ]

  # << SSU >>
  get_SSU_coords:
    run: ../tools/RNA_prediction/SSU-from-tablehits.cwl
    in:
      table_hits: find_ribosomal_ncRNAs/matches
    out: [ SSU_coordinates ]

  extract_SSUs:
    run: ../tools/RNA_prediction/esl-sfetch-manyseqs.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      names: get_SSU_coords/SSU_coordinates
      names_contain_subseq_coords: { default: true }
    out: [ sequences ]

  classify_SSUs:
    run: ../tools/mapseq/mapseq.cwl
    in:
      sequences: extract_SSUs/sequences
      database: mapseq_ref
      taxonomy: mapseq_taxonomy
    out: [ classifications ]

  #Visualisation of taxonomic classification
  convert_classifications_to_otu_counts:
    run: ../tools/RNA_prediction/mapseq2biom.cwl
    in:
       otu_table: mapseq_taxonomy
       label: sequencing_run_id
       query: classify_SSUs/classifications
    out: [ otu_counts, krona_otu_counts ]

  visualize_otu_counts:
    run: ../tools/krona/krona.cwl
    in:
      otu_counts: convert_classifications_to_otu_counts/krona_otu_counts
    out: [ otu_visualization ]

  convert_otu_counts_to_hdf5:
    run: ../tools/RNA_prediction/biom-convert.cwl
    in:
       biom: convert_classifications_to_otu_counts/otu_counts
       hdf5: { default: true }
       table_type: { default: OTU table }
    out: [ result ]

  convert_otu_counts_to_json:
    run: ../tools/RNA_prediction/biom-convert.cwl
    in:
       biom: convert_classifications_to_otu_counts/otu_counts
       json: { default: true }
       table_type: { default: OTU table }
    out: [ result ]