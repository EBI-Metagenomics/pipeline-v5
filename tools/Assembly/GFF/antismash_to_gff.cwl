#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: alpine:3.9.4

baseCommand: [antismash_to_gff.py]

inputs:
  antismash_geneclus:
    type: File
    inputBinding:
      prefix: -g
  antismash_embl:
    type: File
    inputBinding:
      prefix: -e
  antismash_gc_json:
    type: File
    inputBinding:
      prefix: -j
  output_name:
    type: string
    inputBinding:
      prefix: -o

stdout: stdout.txt

outputs:
  output_gff_gz:
    type: File
    outputBinding:
      glob: $(inputs.output_name).gz
  output_gff_index:
    type: File
    outputBinding:
      glob: $(inputs.output_name).gz.tbi
  stdout: stdout