#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Length Filter"

requirements:
  DockerRequirement:
    dockerPull: viral_get_predicted_faa:latest
  InlineJavascriptRequirement: {}

baseCommand: ['python', '/get_predicted_faa.py']

inputs:
  wanted_file:
    type: File
    inputBinding:
      separate: true
      prefix: "-w"
  predicted_file:
    type: File
    inputBinding:
      separate: true
      prefix: "-p"

outputs:
  chosen_faa:
    type: File
    outputBinding:
      glob: '*.faa'
