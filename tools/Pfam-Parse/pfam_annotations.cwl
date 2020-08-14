#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ShellCommandRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 200

hints:
  - class: DockerRequirement
    dockerPull: debian:stable-slim

label: "Parse Pfam hits from Interpro annotation output"

baseCommand: []

inputs:
  interpro:
    type: File
    label: Interpro scan results in TSV format
    format: edam:format_3475
  outputname: string

arguments:
  - awk
  - '/Pfam/'
  - $(inputs.interpro)

stdout: $(inputs.outputname)

outputs:
  annotations:
    type: stdout
    label: Pfam results only
    format: edam:format_3475

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"