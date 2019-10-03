#!/usr/bin/env
cwlVersion: v1.0
class: CommandLineTool
requirements:
  InlineJavascriptRequirement: {}

inputs:
  uncompressed_file:
    type: File
    inputBinding:
      position: 1

baseCommand: [ gzip ]

outputs:
  gziped_file:
    type: File
    outputBinding:
      glob: "*.gz"

hints:
  - class: DockerRequirement
    dockerPull: alpine:3.7

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
