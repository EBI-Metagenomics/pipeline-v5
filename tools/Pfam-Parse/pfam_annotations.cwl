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
    format: edam:format_3475
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
    format: edam:format_3475

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.7'

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:   "EMBL - European Bioinformatics Institute"