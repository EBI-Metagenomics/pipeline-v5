#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: kegg_test:latest

baseCommand: [give_pathways.py]

inputs:
  input_table:
    type: File
    inputBinding:
      separate: true
      prefix: -i
  graphs:
    type: File
    inputBinding:
      prefix: -g
  pathways_names:
    type: File
    inputBinding:
      prefix: -n
  pathways_classes:
    type: File
    inputBinding:
      prefix: -c
  outputname:
    type: string
    inputBinding:
      prefix: -o

stdout: stdout.txt

outputs:
  summary_pathways:
    type: File
    outputBinding:
      glob: "*summary.kegg_pathways*"

  summary_contigs:
    type: File
    outputBinding:
      glob: "*summary.kegg_contigs*"

  stdout: stdout