#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: get float proportion hits covered by SSUs and LSUs

requirements:
    - class: ShellCommandRequirement

inputs:

  all_coordinates:
    type: File
    inputBinding:
      position: 1
    label: LSU and SSU coordinates

  summary:
    type: File
    inputBinding:
      position: 2
    label: merged fasta files summary from qc-stats

  fasta:
    type: File
    inputBinding:
      position: 3
    label: fasta file from trimming reads

baseCommand: [divide]

stdout: division

outputs:
  fasta_output:
    type: File
    outputBinding:
      glob: "*fasta"
