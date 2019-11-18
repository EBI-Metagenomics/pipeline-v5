#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: combine LSU and SSU coords

hints:
  DockerRequirement:
    dockerPull: alpine:3.7

inputs:

  SSU_coords:
    type: File
    inputBinding:
      position: 1

  LSU_coords:
    type: File
    inputBinding:
      position: 2

baseCommand: cat

stdout: SSU-and-LSU

outputs:

  all-coordinates:
    type: stdout
