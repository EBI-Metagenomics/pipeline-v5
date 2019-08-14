#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "eggNOG"

requirements:
  DockerRequirement:
    dockerPull: eggnog_makedb:latest
  InlineJavascriptRequirement: {}

baseCommand: ['bash', '/run_make_db.sh']

inputs: []

stderr: stderr.txt
stdout: stdout.txt

outputs:
  stderr: stderr
  stdout: stdout

  output_files:
    type: File
    outputBinding:
      glob: data/*
