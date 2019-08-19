#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "reformat coords file for masking with bedtools"

requirements:
    DockerRequirement:
        dockerPull: alpine:3.7
inputs:

  all_coordinates:
    type: File
    label: SSU and LSU coordinates combined

baseCommand: [awk]

#reverse start and end where start < end (i.e. neg strand)
arguments:
  - '$2 > $3 { var = $3; $3 = $2; $2 = var } 1 {print $4,$2,$3}'
  - OFS=\t
  - $(inputs.all_coordinates)

stdout: ITS-maskfile

outputs:
  maskfile:
    type: stdout
