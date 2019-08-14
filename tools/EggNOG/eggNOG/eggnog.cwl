#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "eggNOG"

requirements:
  DockerRequirement:
    dockerPull: eggnog_pipeline:latest
  InlineJavascriptRequirement: {}

baseCommand: ['python', '/emapper.py']
arguments:
  - valueFrom: "16"
    prefix: --cpu
  - valueFrom: diamond
    prefix: -m
  - valueFrom: /Users/kates/Desktop/CWL_eggNOG/eggnog
    prefix: -o


inputs:
  fasta_file:
    type: File
    inputBinding:
      separate: true
      prefix: "-i"

  db:
    type: File?
    default:
      class: File
      path: /Users/kates/Desktop/CWL_eggNOG/eggnog-mapper/data/eggnog.db
      listing: []
      basename: data/eggnog.db
    inputBinding:
      prefix: --database

  db_diamond:
    type: File?
    default:
      class: File
      path: /Users/kates/Desktop/CWL_eggNOG/eggnog-mapper/data/eggnog_proteins.dmnd
      listing: []
      basename: data/eggnog_proteins.dmnd
    inputBinding:
      prefix: --dmnd_db

  data_dir:
    type: Directory?
    default:
      class: Directory
      path: /Users/kates/Desktop/CWL_eggNOG/eggnog-mapper/data/
      listing: []
      basename: data
    inputBinding:
      prefix: --data_dir

stderr: stderr.txt
stdout: stdout.txt

outputs:
  stderr: stderr
  stdout: stdout

  output_annotations:
    type: File
    outputBinding:
      glob: eggnog.emapper.annotations

  output_orthologs:
    type: File
    outputBinding:
      glob: eggnog.emapper.seed_orthologs