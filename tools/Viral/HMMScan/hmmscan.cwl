#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool


label: "Biosequence analysis using profile hidden Markov models"

requirements:
  DockerRequirement:
    dockerPull: mgnify/hmmscan:latest
  InlineJavascriptRequirement: {}

baseCommand: ["hmmscan"]

arguments:

  - prefix: -E
    valueFrom: "0.001"
    position: 2
  - prefix: --domtblout
    valueFrom: $(inputs.seqfile.nameroot)_hmmscan.tbl
    position: 3
  - valueFrom: /vpHMM_database/vpHMM_database
    position: 4
  - valueFrom: --noali
    position: 1

inputs:

  seqfile:
    type: File
    inputBinding:
      position: 5
      separate: true

stdout: stdout.txt

outputs:

  output_table:
    type: File
    outputBinding:
      glob: "*hmmscan.tbl"