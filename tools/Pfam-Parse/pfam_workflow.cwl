#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow

inputs:
  interpro_file: File

outputs:
  pfam_annotations:
    type: File
    outputSource: parse/annotations
  pfam_summary:
    type: File
    outputSource: frequency/summary

steps:
  parse:
    run: pfam_annotations.cwl
    in:
      interpro: interpro_file
    out: [annotations]

  frequency:
    run: pfam_summary.cwl
    in:
      pfam_only: parse/annotations
    out: [summary]
