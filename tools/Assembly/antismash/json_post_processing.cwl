#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: alpine:3.9.4

baseCommand: [antismash_json_post_processing.sh]

inputs:
  antismash_geneclus:
    type: File
    inputBinding:
      prefix: -i

outputs:
  output_json:
    type: File
    outputBinding:
      glob: "geneclusters.json"
