#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

label: "extract ncrnas!"

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  deoverlapped_matches:
    type: File
  model:
    type: File
  indexed_sequences: {type: File, secondaryFiles: [.ssi] }
  script:
    type: File

outputs:
  ncrna_matches:
    type: File
    outputSource: extract_ncrna/sequences
  ncrna_hits:
    type: File
    outputSource: get_hits/matches

steps:

  get_hits:
    run: pull_ncrnas.cwl
    in:
      hits: deoverlapped_matches
      model: model
      script: script
    out: [ matches ]

  extract_coords:
    run: ../../../../../../pipeline_v5/pipeline-v5/tools/RNA_prediction/extract-coords-from-cmsearch.cwl
    in:
      infernal_matches: get_hits/matches
    out: [ matched_seqs_with_coords ]

  extract_ncrna:
      run: ../../../../../../pipeline_v5/pipeline-v5/tools/easel/esl-sfetch-manyseqs.cwl
      in:
        indexed_sequences: indexed_sequences
        names_contain_subseq_coords: extract_coords/matched_seqs_with_coords
      out: [ sequences ]
