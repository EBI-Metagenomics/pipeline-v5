#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool


label: "Parsing viral predicted files"

requirements:
  DockerRequirement:
    dockerPull: cwl_parse_pred:latest
  InlineJavascriptRequirement: {}

baseCommand: ['python', '/vs_vf_categories.py']

inputs:
  assembly:
    type: File
    inputBinding:
      separate: true
      prefix: "-a"
  virfinder_tsv:
    type: File?
    inputBinding:
      separate: true
      prefix: "-f"
  virsorter_dir:
    type: Directory?
    default:
      class: Directory
      path:  ../../../workflows/
      listing: []
    inputBinding:
      separate: true
      prefix: "-s"
  output_dir:
    type: string?
    inputBinding:
      separate: true
      prefix: "-o"

stdout: stdout.txt
stderr: stderr.txt

outputs:
  stdout: stdout
  stderr: stderr

  output_array:
    type:
      type: array
      items: Directory
    outputBinding:
      glob: "*_*"


doc: |
  usage: parse_viral_pred.py [-h] -a ASSEMB -f FINDER -s SORTER [-o OUTDIR]

  description: script generates three output_files: High_confidence.fasta, Low_confidence.fasta, Prophages.fasta

  optional arguments:
  -h, --help            show this help message and exit
  -a ASSEMB, --assemb ASSEMB
                        Metagenomic assembly fasta file
  -f FINDER, --vfout FINDER
                        Absolute or relative path to VirFinder output file
  -s SORTER, --vsdir SORTER
                        Absolute or relative path to directory containing
                        VirSorter output
  -o OUTDIR, --outdir OUTDIR
                        Absolute or relative path of directory where output
                        viral prediction files should be stored (default: cwd)
