#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "antiSMASH"

requirements:
  InlineJavascriptRequirement: {}

inputs:
  input_fasta:
    type: File

arguments:
  - valueFrom: ..$(inputs.input_fasta.path)
    position: 5

  - valueFrom: --knownclusterblast
    position: 1
  - valueFrom: $(runtime.outdir)/katya-antismash
    prefix: --outputfolder
    position: 2
  - valueFrom: "-v"
    position: 3

stdout: stdout.txt
stderr: stderr.txt

outputs:
  stdout: stdout
  stderr: stderr

  output_files:
    type: Directory
    outputBinding:
      glob: katya-antismash
