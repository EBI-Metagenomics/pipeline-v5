#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

#hints:
# DockerRequirement:
#   dockerPull: 'alpine:3.7'

requirements:
  ResourceRequirement:
    ramMin: 10000
    coresMin: 16
  InlineJavascriptRequirement: {}

baseCommand: [add_header.sh]

inputs:
  input_table:
    type: File
    inputBinding:
      position: 1
      prefix: -i

outputs:
  output_table:
    type: File
    outputBinding:
      glob: 'hmmscan_result.tbl'