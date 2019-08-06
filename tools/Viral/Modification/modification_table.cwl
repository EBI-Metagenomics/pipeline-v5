#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
requirements:
  DockerRequirement:
    dockerPull: sed_docker:latest

baseCommand: ['sed', '/^#/d; s/ \+/\t/g']

inputs:
  table_for_modification:
    type: File
    inputBinding:
      separate: true
      position: 2

outputs:
  output_with_tabs:
    type: stdout