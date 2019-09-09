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
#  SchemaDefRequirement:
#    types:
#      - $import: ../tools/biom-convert/biom-convert-table.yaml

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
  otu_unite_label: string
  otu_itsone_label: string

outputs: []


#ADD QUALITY CONTROLLED READS

steps:

  cat:
    run: ../tools/mask-for-ITS/cat-SSU-LSU.cwl
    in:
      SSU_coords: SSU_coordinates
      LSU_coords: LSU_coordinates
    out: [ all-coordinates ]
