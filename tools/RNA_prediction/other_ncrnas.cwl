#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

label: "extract ncrnas!"

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  ShellCommandRequirement: {}

inputs:
  indexed_sequences: {type: File, secondaryFiles: [.ssi] }
  other_ncRNA_ribosomal_models: File[]
  other_ncRNA_ribosomal_model_clans: File
  script: File

outputs:
  ncrnas:
    type:
      type: array
      items: File
    outputSource: get_ncrnas/ncrna_matches

steps:

  find_ribosomal_ncRNAs:
    run: ../../../../../../pipeline_v5/pipeline-v5/workflows/cmsearch-multimodel-wf.cwl
    in:
      query_sequences: indexed_sequences
      covariance_models: other_ncRNA_ribosomal_models
      clan_info: other_ncRNA_ribosomal_model_clans
    out: [ deoverlapped_matches ]

  get_ncrnas:
    run: extract_ncrnas.cwl
    scatter: model
    in:
      indexed_sequences: indexed_sequences
      model: other_ncRNA_ribosomal_models
      deoverlapped_matches: find_ribosomal_ncRNAs/deoverlapped_matches
      script: script
    out: [ ncrna_matches, ncrna_hits ]






