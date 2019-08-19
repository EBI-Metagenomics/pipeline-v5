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
      position: 2
    label: LSU and SSU coordinates

  summary:
    type: File
    inputBinding:
      position: 3
    label: merged fasta files summary from qc-stats

  script:
    type: File
    inputBinding:
      position: 1
    label: bash script

baseCommand: [sh]

stdout: division

outputs:
  proportion:
    type: stdout
