#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow


label: "Post processing hmmscan output"

requirements:
  InlineJavascriptRequirement: {}
  SubworkflowFeatureRequirement: {}

inputs:
  input_table:
    type: File

outputs:
  modified_file:
    outputSource: add_title/stdout
    type: File

steps:
  tab_modification:
    in:
      table_for_modification: input_table
    out:
      - output_with_tabs
    run: modification_table.cwl

  expression_modification:
    in: []
    out:
      - output_echo
    run: echo_modification_table.cwl

  add_title:
    in:
      input_file: input_table
      title: expression_modification/output_echo
      data: tab_modification/output_with_tabs
    out:
      - stdout
    run: add_title_modification.cwl

