#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.9.4'

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