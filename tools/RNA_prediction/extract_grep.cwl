#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

#requirements:
# DockerRequirement:
#    dockerPull: alpine:3.7

inputs:
  input_file:
    type: File
    inputBinding:
      prefix: -i
  pattern:
    type: string
    inputBinding:
      prefix: -p

baseCommand: grep_tool

outputs:
  grepped_file:
    type: File
    outputBinding:
      glob: '*.grepped'
