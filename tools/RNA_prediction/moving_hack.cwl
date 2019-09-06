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
      position: 0

baseCommand: mv

arguments:
  - valueFrom: $(inputs.input_file.nameroot)_mv
    position: 1

outputs:
  moved_file:
    type: File
    outputBinding:
      glob: "*_mv"