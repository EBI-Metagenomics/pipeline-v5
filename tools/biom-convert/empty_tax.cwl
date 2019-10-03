#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: rename empty tax files and add mock bacteria to empty otu table
#this to avoid errors with empty files further down the pipeline

#requirements:
#    - class: ShellCommandRequirement

inputs:
  mapseq:
    type: File
    inputBinding:
      position: 1

  otutable:
    type: File
    inputBinding:
      position: 2

  biomtable:
    type: File
    inputBinding:
      position: 3

  krona:
    type: File
    inputBinding:
      position: 4

baseCommand: [empty_tax.sh]

outputs:
  mapseq_out:
    type: File
    outputBinding:
      glob: "*.mseq"

  otu_out:
    type: File
    outputBinding:
      glob: "*.tsv"

  biom_out:
    type: File
    outputBinding:
      glob: "*.txt"

  krona_out:
    type: File
    outputBinding:
      glob: "*.html"