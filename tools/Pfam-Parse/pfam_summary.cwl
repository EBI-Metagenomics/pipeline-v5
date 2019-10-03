#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
    - class: ShellCommandRequirement

label: "Frequency of Pfam hits calculated from annotations file"

inputs:
  pfam_only:
    type: File
    label: Pfam only results in TSV
    #format: edam:format_3475

baseCommand: []

arguments:
  - cut
  - -f
  - '5,6'
  - $(inputs.pfam_only)
  - '|'
  - sort
  - '|'
  - uniq
  - -c

stdout: $(inputs.pfam_only.nameroot).summary.pfam

outputs:
  summary:
    type: stdout
    label: Frequency of each Pfam hit
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
