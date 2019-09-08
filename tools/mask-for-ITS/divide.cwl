#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "get proportion of LSU/SSU hits to total seqs and rename file prefix to EMPTY if >90%"

requirements:
    - class: ShellCommandRequirement

inputs:

  fasta_SSU:
    type: File
    inputBinding:
      position: 1

  fasta_LSU:
    type: File
    inputBinding:
      position: 2

  summary:
    type: File
    inputBinding:
      position: 3
    label: merged fasta files summary from qc-stats

  fasta:
    type: File
    inputBinding:
        position: 4

baseCommand: [divide]

outputs:

  fasta_out:
    type: File
    outputBinding:
        glob: "*.fasta"
