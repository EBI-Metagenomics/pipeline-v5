#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

label: Subworkflow unites Diamond and Diamond post-processing

requirements:
  SubworkflowFeatureRequirement: {}
  ResourceRequirement:
    ramMin: 30000
    coresMin: 32

inputs:
  queryInputFile: File
  outputFormat: string
  maxTargetSeqs: int
  strand: string
  databaseFile: [string, File]
  threads: int
  Uniref90_db_txt: [string, File]
  filename: string

outputs:
  diamond_output:
    type: File
    outputSource: diamond_run/matches
  post-processing_output:
    type: File
    outputSource: post_processing_uniref90/join_out

steps:
  diamond_run:
    in:
      queryInputFile: queryInputFile
      outputFormat: outputFormat
      maxTargetSeqs: maxTargetSeqs
      strand: strand
      databaseFile: databaseFile
      threads: threads
    out: [ matches ]
    run: Diamond.blastp.cwl

  post_processing_uniref90:
    in:
      input_diamond: diamond_run/matches
      input_db: Uniref90_db_txt
      filename: filename
    out: [join_out]
    run: Diamond-Post-Processing/postprocessing_subwf.cwl

$namespaces:
 s: http://schema.org/
$schemas:
 - 'http://edamontology.org/EDAM_1.20.owl'
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2019"
s:author: "Ekaterina Sakharova"