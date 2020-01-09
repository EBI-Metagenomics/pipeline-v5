#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "antiSMASH"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 200  # just a default, could be lowered


hints:
  DockerRequirement:
    dockerPull: 'alpine:3.7'

inputs:
  outputname:
    type: string
    inputBinding:
      prefix: -o

  input_js:
    type: File
    inputBinding:
      prefix: -i

baseCommand: [antismash_json_generation]

outputs:
  output_json:
    type: File
    outputBinding:
      glob: $(inputs.outputname)
