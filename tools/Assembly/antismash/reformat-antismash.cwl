#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "antiSMASH"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 200

inputs:
  glossary:
    type: File
    inputBinding:
      position: 1
      prefix: -g
  geneclusters:
    type: File
    inputBinding:
        position: 2
        prefix: -a

baseCommand: [reformat-antismash.py]

outputs:
  reformatted_clusters:
    type: File
    outputBinding:
      glob: geneclusters-summary.txt