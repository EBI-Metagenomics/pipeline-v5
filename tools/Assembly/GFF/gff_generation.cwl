#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: alpine:3.9.4

baseCommand: [build_assembly_gff.py]

inputs:
  ips_results:
    type: File
    inputBinding:
      prefix: -i
  eggnog_results:
    type: File
    inputBinding:
      prefix: -e
  input_faa:
    type: File
    inputBinding:
      prefix: -f
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