#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

#requirements:
#  DockerRequirement:
#    dockerPull: alpine:3.9.4

baseCommand: [split_by_contigs.py]

inputs:
  input_table:
    type: File
    inputBinding:
      prefix: -i

outputs:
  files_by_contigs:
    type: File[]
    outputBinding:
      glob: 'contigs/*'