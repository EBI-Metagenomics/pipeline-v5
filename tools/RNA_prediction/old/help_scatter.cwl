#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

#requirements:
# DockerRequirement:
#    dockerPull: alpine:3.7

inputs:
  input_files:
    type: File[]
    inputBinding:
      position: 0
  output_filename_ssu:
    type: string
    inputBinding:
      position: 1
  output_filename_lsu:
    type: string
    inputBinding:
      position: 2
  output_filename_5s:
    type: string
    inputBinding:
      position: 3

baseCommand: help_script

outputs:
  ssu_file:
    type: File
    outputBinding:
      glob: 'SSU*'
  lsu_file:
    type: File
    outputBinding:
      glob: 'LSU*'
  5s_file:
    type: File
    outputBinding:
      glob: '5S*'