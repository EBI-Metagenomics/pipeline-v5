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
      location: combined_gene_caller_conf.json
      basename: combined_gene_caller_conf
    inputBinding:
      prefix: "-c"

stdout: stdout.txt
stderr: stderr.txt


outputs:
  stdout: stdout
  stderr: stderr

  predicted_proteins:
    type: File
    outputBinding:
      glob: "$(inputs.input_fasta.basename).faa"

  predicted_seq:
    type: File
    outputBinding:
      glob: "$(inputs.input_fasta.basename).ffn"
  gene_caller_out:
    type: File
    outputBinding:
      glob: "$(inputs.input_fasta.basename).out"
