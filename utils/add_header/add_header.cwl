#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

#hints:
#  DockerRequirement:
#    dockerPull: 'alpine:3.7'

requirements:
  ResourceRequirement:
    ramMin: 1000
    coresMin: 8
  InlineJavascriptRequirement: {}

baseCommand: [ add_header ]

inputs:
  input_table:
    type: File
    inputBinding:
      prefix: -i
  output_name:
    type: string
    inputBinding:
      prefix: -o
  header:
    type: string
    inputBinding:
      prefix: -h

outputs:
  output_table:
    type: File
    outputBinding:
      glob: $(inputs.output_name)