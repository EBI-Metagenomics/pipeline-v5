#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Amplicon and ITS Workflow"

requirements:
  - class: ShellCommandRequirement
  - ScatterFeatureRequirement: {}
  - SubworkflowFeatureRequirement: {}

inputs:
  input_sequences: File
  silva_database: File
    secondaryFiles: .mscluster
  silva_taxonomy: File
  silva_otus: File
  unite_database: File
    secondaryFiles: .mscluster
  unite_taxonomy: File
  unite_otus: File
  itsone_database: File
    secondaryFiles: .mscluster
  itsone_taxonomy: File
  itsone_otus: File
  ncRNA_ribosomal_models: File
  ncRNA_ribosomal_model_clans: File
  divide_script: File

outputs:
  ncRNAs:
    type: File
    outputSource: find_ribosomal_ncRNAs/deoverlapped_matches

  SSU_fasta:
    type: File
    outputSource: extract_SSUs/SSU-sequences

  LSU_fasta:
    type: File
    outputSource: extract_LSUs/LSU-sequences

  SSU_classifications:
    type: File
    outputSource: classify_SSUs/classifications

  SSU_otu_tsv:
    type: File
    outputSource: classify_SSUs/otu_counts

  SSU_krona_image:
    type: File
    outputSource: classify_SSUs/otu_visualization

  LSU_classifications:
    type: File
    outputSource: classify_LSUs/classifications

  LSU_otu_tsv:
    type: File
    outputSource: classify_LSUs/otu_counts

  LSU_krona_image:
    type: File
    outputSource: classify_LSUs/otu_visualization

  unite_classifications:
    type: File
    outputSource: run_unite/classifications

  unite_otu_tsv:
    type: File
    outputSource: run_unite/otu_counts

  unite_krona_image:
    type: File
    outputSource: run_unite/otu_visualization

  itsonedb_classifications:
    type: File
    outputSource: run_itsonedb/classifications

  itsonedb_otu_tsv:
    type: File
    outputSource: run_itsonedb/otu_counts

  itsonedb_krona_image:
    type: File
    outputSource: run_itsonedb/otu_visualization


#ADD QUALITY CONTROLLED READS

steps:

#find SSU and LSU and get coords

  find_ribosomal_ncRNAs:
    run: ../cmsearch-multimodel.cwl
    in:
      query_sequences: input_sequences
      covariance_models: ncRNA_ribosomal_models
      clan_info: ncRNA_ribosomal_model_clans
    out: [ deoverlapped_matches ]

  index_reads:
    run: ../tools/easel/esl-sfetch-index.cwl
    in:
      sequences: input_sequences
    out: [ sequences ]
      secondaryFiles: .ssi

  get_SSU_coords:
    run: ../SSU-from-tablehits.cwl
    in:
      table_hits: find_ribosomal_ncRNAs/deoverlapped_matches
    out: [ SSU_coordinates ]

  get_LSU_coords:
    run: ../LSU-from-tablehits.cwl
    in:
      table_hits: find_ribosomal_ncRNAs/deoverlapped_matches
    out: [ LSU_coordinates ]

#extract LSU and SSU
#mapseq SILVA

  extract_SSUs:
      run: ../tools/easel/esl-sfetch-manyseqs.cwl
      in:
        indexed_sequences: index_reads/sequences_with_index
        names: get_SSU_coords/LSU_coordinates
        names_contain_subseq_coords: { default: true }
      out: [ SSU-sequences ]

  classify_SSUs:
    run: ../classify-otu-visualise.cwl
    in:
      fasta: extract_SSUs/SSU-sequences
      mapseq_ref: silva_database
        secondaryFiles: .mscluster
      mapseq_taxonomy: silva_taxonomy
      otu_ref: silva_otus
    out: [ classifications, otu_counts, krona_otu_counts, otu_visualization ]

  extract_LSUs:
      run: ../tools/easel/esl-sfetch-manyseqs.cwl
      in:
        indexed_sequences: index_reads/sequences_with_index
        names: get_LSU_coords/LSU_coordinates
        names_contain_subseq_coords: { default: true }
      out: [ SSU-sequences ]

  classify_SSUs:
    run: ../classify-otu-visualise.cwl
    in:
      fasta: extract_LSUs/LSU-sequences
      mapseq_ref: silva_database
        secondaryFiles: .mscluster
      mapseq_taxonomy: silva_taxonomy
      otu_ref: silva_otus
    out: [ classifications, otu_counts, krona_otu_counts, otu_visualization ]

#ITS pipeline starts here!
#mask the SSU and LSU

  cat:
    run: ../tools/cat_LSU_SSU.cwl
    in:
      SSU-coords: get_SSU_coords/SSU_coordinates
      LSU-coords: get_LSU_coords/LSU_coordinates
    out: [ all_coordinates ]

  match_proportion:
    run: ../tools/divide.cwl
    in:
      script: divisions
      coordinates: cat/all_coordinates
      stats: qc??/summary
    out: [proportion]

  #if proportion < 0.90 then carry on, update with potential "conditional"
  #or run as two subworkflows

  reformat_coords:
    run: ../tools/easel/reformat-for-eslmask.cwl
    in:
      coordinates: cat/all_coordinates
    out: [ esl_maskfile ]

  mask_for_ITS:
    run: ../tools/easel/esl-mask.cwl
    in:
      fasta: input_sequences
        secondaryFiles: .ssi
      maskfile: reformat_coords/esl_maskfile
    out: [masked_fasta]


#run unite and ITSone

  run_unite:
    run: ../classify-otu-visualise.cwl
    in:
      fasta: mask_for_ITS/masked_fasta
      mapseq_ref: unite_database
        secondaryFiles: .mscluster
      mapseq_taxonomy: unite_taxonomy
      otu_ref: unite_otus
    out: [ classifications, otu_counts, krona_otu_counts, otu_visualization ]

  run_itsonedb:
    run: ../classify-otu-visualise.cwl
    in:
      fasta: mask_for_ITS/masked_fasta
      mapseq_ref: itsone_database
        secondaryFiles: .mscluster
      mapseq_taxonomy: itsone_taxonomy
      otu_ref: itsone_otus
    out: [ classifications, otu_counts, krona_otu_counts, otu_visualization ]
