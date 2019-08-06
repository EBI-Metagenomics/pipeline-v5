#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Viral contig annotation"

requirements:
  DockerRequirement:
    dockerPull: annotation_viral_contigs:latest
  InlineJavascriptRequirement: {}

baseCommand: ['python', '/viral_contigs_annotation.py']
arguments: ["-o", $(runtime.outdir)]

inputs:
  input_faa:
    type: File
    inputBinding:
      separate: true
      prefix: "-p"
  input_table:
    type: File
    inputBinding:
      separate: true
      prefix: "-t"
  input_fna:
    type: File?
    inputBinding:
      separate: true
      prefix: "-n"

stdout: stdout.txt
stderr: stderr.txt

outputs:
  stdout: stdout
  stderr: stderr
  annotation_table:
    type: File
    outputBinding:
      glob: "*_ann_table.tsv"