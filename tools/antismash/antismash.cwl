#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "antiSMASH"

requirements:
  DockerRequirement:
    dockerPull: antismash/standalone:5.0.0
  InlineJavascriptRequirement: {}


inputs:
  input_fasta:
    type: File


arguments:
  - valueFrom: ..$(inputs.input_fasta.path)
    position: 1
  - valueFrom: prodigal
    prefix: --genefinding-tool
    separate: true
    position: 3
  - valueFrom: --cb-knownclusters
    position: 4
  - valueFrom: $(runtime.outdir)/output
    prefix: --output-dir
    position: 5


stdout: stdout.txt
stderr: stderr.txt

outputs:
  stdout: stdout
  stderr: stderr

  output_files:
    type: Directory
    outputBinding:
      glob: output
