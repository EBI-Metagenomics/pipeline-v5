#!/usr/bin/env
cwlVersion: v1.0
class: CommandLineTool

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

requirements:
  InlineJavascriptRequirement: {}
  ShellCommandRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 200  # just a default, could be lowered

hints:
  - class: DockerRequirement
    dockerPull: debian:stable-slim

inputs:
  sequences:
    type: File
    streamable: true
    # format: edam:format_1929  # FASTA
  number:
    type: int

baseCommand: []

arguments:
    - grep
    - -c
    - '^>'
    - $(inputs.sequences)
    - '|'
    - cat

stdout: count

outputs:
  count:
    type: int
    outputBinding:
      glob: count
      loadContents: true
      outputEval: $((Number(self[0].contents)/inputs.number) | 0)


$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
