#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Length Filter"

requirements:
  DockerRequirement:
    dockerPull: viral_pipeline:latest
  InlineJavascriptRequirement: {}

baseCommand: ['python', '/get_predicted_faa.py']

inputs:
  wanted_folder:
    type: Directory
    inputBinding:
      separate: true
      prefix: "-w"
  predicted_file:
    type: File
    inputBinding:
      separate: true
      prefix: "-p"

stdout: stdout.txt
stderr: stderr.txt

outputs:
  stdout: stdout
  stderr: stderr

  chosen_faa:
    type: File
    outputBinding:
      glob: '*.faa'
