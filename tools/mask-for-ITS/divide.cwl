#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "get proportion of LSU/SSU hits to total seqs and rename file prefix to EMPTY if >90%"

requirements:
    - class: ShellCommandRequirement

inputs:

  all_coordinates:
    type: File
    inputBinding:
      position: 2
    label: LSU and SSU coordinates

  fasta:
    type: File
    inputBinding:
        position: 4

  summary:
    type: File
    inputBinding:
      position: 3
    label: merged fasta files summary from qc-stats

baseCommand: [divide]

outputs:

  fasta_out:
    type: File
    outputBinding:
        glob: "*.fasta"
