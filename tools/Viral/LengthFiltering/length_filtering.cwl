#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Length Filter"

requirements:
  DockerRequirement:
    dockerPull: cwl_length_filter_docker:latest
  InlineJavascriptRequirement: {}

baseCommand: ['python', '/filter_contigs_len.py']
arguments: ["-l", "0.5"]

inputs:
  fasta_file:
    type: File
    inputBinding:
      separate: true
      prefix: "-f"
  outdir:
    type: Directory?
    inputBinding:
      separate: true
      prefix: "-o"
  identifier:
    type: string?
    inputBinding:
      separate: true
      prefix: "-i"

outputs:
  filtered_contigs_fasta:
    type: File
    outputBinding:
      glob: '*_filt*.fasta'


doc: |
  usage: filter_contigs_len.py [-h] -f input_file -l length_thres -o output_dir -i sample_id

  Extract sequences at least X kb long.

  positional arguments:
    fasta              Path to fasta file to filter

  optional arguments:
    -h, --help         show this help message and exit
    -l LENGTH          Length threshold in kb of selected sequences (default: 5kb)
    -o OUTDIR          Relative or absolute path to directory where you want to store output (default: cwd)
    -i IDENT           Dataset identifier or accession number. Should only be introduced if you want to add it to each sequence header, along with a sequential number

