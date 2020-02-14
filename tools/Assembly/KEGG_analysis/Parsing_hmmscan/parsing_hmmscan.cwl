#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool


label: "Biosequence analysis using profile hidden Markov models"

hints:
  DockerRequirement:
    dockerPull: kegg_analysis:latest

requirements:
  InlineJavascriptRequirement: {}

baseCommand: ['parsing_hmmscan.py']

inputs:
  table:
    type: File
    inputBinding:
      separate: true
      prefix: -i
  fasta:
    type: File
    inputBinding:
      separate: true
      prefix: -f

stdout: stdout.txt
stderr: stderr.txt

outputs:

  output_table:
    type: File
    outputBinding:
      glob: "*_parsed*"