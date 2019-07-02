#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
requirements:
  DockerRequirement:
    dockerPull: linux_docker_diamond:latest

baseCommand: ['sort', '-k2,2']

inputs:
  input_table:
    type: File
    inputBinding:
      separate: true
      position: 2

stdout: $(inputs.input_table.nameroot)_sorted

outputs:
  output_sorted:
    type: stdout