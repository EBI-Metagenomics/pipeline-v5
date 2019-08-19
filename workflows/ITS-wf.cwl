#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Amplicon and ITS Workflow"

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}
  SchemaDefRequirement:
    types:
      - $import: ../tools/biom-convert/biom-convert-table.yaml

inputs:
  qc_stats_summary: File
  query_sequences: File
  LSU_coordinates: File
  SSU_coordinates: File
  unite_database: {type: File, secondaryFiles: [.mscluster] }
  unite_taxonomy: File
  unite_otus: File
  itsone_database: {type: File, secondaryFiles: [.mscluster] }
  itsone_taxonomy: File
  itsone_otus: File
  divide_script: File
  otu_unite_label: string
  otu_itsone_label: string

outputs:
  proportion_SU:
    type: File
    outputSource: match_proportion/proportion

  masked_sequences:
    type: File
    outputSource: mask_for_ITS/masked_fasta

  unite_classifications:
    type: File
    outputSource: run_unite/mapseq_classifications

  unite_otu_tsv:
    type: File
    outputSource: run_unite/krona_tsv

  unite_krona_image:
    type: File
    outputSource: run_unite/krona_image

  itsonedb_classifications:
    type: File
    outputSource: run_itsonedb/mapseq_classifications

  itsonedb_otu_tsv:
    type: File
    outputSource: run_itsonedb/krona_tsv

  itsonedb_krona_image:
    type: File
    outputSource: run_itsonedb/krona_image

  unite_hdf5_classifications:
    type: File
    outputSource: unite_otu_counts_to_hdf5/result

  unite_json_classifications:
    type: File
    outputSource: unite_otu_counts_to_json/result

  itsonedb_hdf5_classifications:
    type: File
    outputSource: itsonedb_otu_counts_to_hdf5/result

  itsonedb_json_classifications:
    type: File
    outputSource: itsonedb_otu_counts_to_json/result

#ADD QUALITY CONTROLLED READS

steps:

#ITS pipeline starts here!
#check proportion LSU/SSU to total seqs.

  cat:
    run: ../tools/mask-for-ITS/cat_LSU_SSU.cwl
    in:
      SSU-coords: SSU_coordinates
      LSU-coords: LSU_coordinates
    out: [ all_coordinates ]

  match_proportion:
    run: ../tools/mask-for-ITS/divide.cwl
    in:
      script: divide_script
      coordinates: cat/all_coordinates
      stats: qc_stats_summary
    out: [proportion]

  #if proportion < 0.90 then carry on, update with potential "conditional"
  #mask SSU/LSU

  reformat_coords:
    run: ../tools/mask-for-ITS/format-bedfile.cwl
    in:
      coordinates: cat/all_coordinates
    out: [ bedfile ]

  mask_for_ITS:
    run: ../tools/mask-for-ITS/bedtools.cwl
    in:
      sequences: query_sequences
      maskfile: reformat_coords/bedfile
    out: [masked_fasta]

#run unite and ITSonedb

  run_unite:
    run: classify-otu-visualise.cwl
    in:
      fasta: mask_for_ITS/masked_fasta
      mapseq_ref: unite_database
      mapseq_taxonomy: unite_taxonomy
      otu_ref: unite_otus
      otu_label: otu_unite_label
    out: [ mapseq_classifications, krona_tsv, krona_txt, krona_image ]

  run_itsonedb:
    run: classify-otu-visualise.cwl
    in:
      fasta: mask_for_ITS/masked_fasta
      mapseq_ref: itsone_database
      mapseq_taxonomy: itsone_taxonomy
      otu_ref: itsone_otus
      otu_label: otu_itsone_label
    out: [ mapseq_classifications, krona_tsv, krona_txt, krona_image ]

#get json and hdf5 files

  unite_otu_counts_to_hdf5:
    run: ../tools/biom-convert/biom-convert.cwl
    in:
       biom: run-unite/krona_tsv
       hdf5: { default: true }
       table_type: { default: 'OTU table' }
    out: [ result ]

  unite_otu_counts_to_json:
    run: ../tools/biom-convert/biom-convert.cwl
    in:
       biom: run_unite/krona_tsv
       json: { default: true }
       table_type: { default: 'OTU table' }
    out: [ result ]

  itsonedb_otu_counts_to_hdf5:
    run: ../tools/biom-convert/biom-convert.cwl
    in:
       biom: run_itsonedb/krona_tsv
       hdf5: { default: true }
       table_type: { default: 'OTU table' }
    out: [ result ]

  itsonedb_otu_counts_to_json:
    run: ../tools/biom-convert/biom-convert.cwl
    in:
       biom: run_itsonedb/krona_tsv
       json: { default: true }
       table_type: { default: 'OTU table' }
    out: [ result ]
