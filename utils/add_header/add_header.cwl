#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

#hints:
#  DockerRequirement:
#    dockerPull: 'alpine:3.7'

requirements:
  ResourceRequirement:
    ramMin: 200
    coresMin: 8
  InlineJavascriptRequirement: {}

baseCommand: [ add_header ]

inputs:
  input_table:
    type: File
    inputBinding:
      prefix: -i
  header:
    type: string
    inputBinding:
      prefix: -h

stdout: $(inputs.input_table.nameroot)

outputs:
  output_table:
    type: stdout