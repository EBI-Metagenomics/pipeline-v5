#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.9.4'

baseCommand: cat

inputs:
  input_file:
    type: File
  title:
    type: File
    inputBinding:
      position: 1
  data:
    type: File
    inputBinding:
      position: 2

stdout: $(inputs.input_file.nameroot)_modified.faa
outputs:
  stdout: stdout