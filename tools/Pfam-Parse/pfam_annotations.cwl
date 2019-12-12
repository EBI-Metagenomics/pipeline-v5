#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ShellCommandRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 200

label: "Parse Pfam hits from Interpro annotation output"

inputs:
  interpro:
    type: File
    label: Interpro scan results in TSV format
    #format: edam:format_3475
  outputname: string

baseCommand: []

arguments:
  - awk
  - '/Pfam/'
  - $(inputs.interpro)

stdout: $(inputs.outputname)

outputs:
  annotations:
    type: stdout
    label: Pfam results only
    #format: edam:format_3475

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.7'

#$namespaces:
  #edam:http://edamontology.org/
#$schemas:

#'s:author': ''
#'s:copyrightHolder': EMBL - European Bioinformatics Institute
#'s:license': ''
