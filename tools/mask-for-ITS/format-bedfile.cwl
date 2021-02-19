#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: "reformat coords file for masking with bedtools"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100

hints:
   DockerRequirement:
      dockerPull: microbiomeinformatics/pipeline-v5.bash-scripts:v1.3

inputs:
  all_coordinates:
    type: File
    label: SSU and LSU coordinates combined
    inputBinding:
      prefix: '-i'

baseCommand: [ format_bedfile ]

#reverse start and end where start < end (i.e. neg strand)

stdout: ITS-maskfile

outputs:
  maskfile:
    type: stdout
