#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  input_diamond:
    type: File
  input_db:
    type: File

outputs:
  join_out:
    outputSource: join/output_join
    type: File

steps:
  sorting:
    in:
      input_table: input_diamond
    out:
      - output_sorted
    run: diamond_sorting.cwl

  join:
    in:
      input_diamond: sorting/output_sorted
      input_db: input_db
    out:
      - output_join
    run: diamond_join.cwl