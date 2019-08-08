#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Combined Gene Caller"

requirements:
  DockerRequirement:
    dockerPull: gene_caller:latest
  InlineJavascriptRequirement: {}

baseCommand: ['/usr/bin/python2.7', '/combined_gene_caller.py']
arguments: ["-v", "-s", "a"]

inputs:
  input_fasta:
    type: File
    inputBinding:
      separate: true
      prefix: "-i"

  config:
    type: File?
    default:
      class: File
      path: combined_gene_caller_conf.json
      listing: []
      basename: combined_gene_caller_conf.json
    inputBinding:
      prefix: "-c"

stdout: stdout.txt
stderr: stderr.txt


outputs:
  stdout: stdout
  stderr: stderr

  output_array:
    type:
      type: array
      items: File
    outputBinding:
      glob: "$(inputs.input_fasta.basename)*"

