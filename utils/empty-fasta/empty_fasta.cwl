#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: create dummy for empty fasta files
#this to avoid errors with empty files further down the pipeline

requirements:
  ResourceRequirement:
    ramMin: 100  # just a default, could be lowered

hints:
  - class: DockerRequirement
    dockerPull: alpine:3.7

#requirements:
#    - class: ShellCommandRequirement

inputs:
  fasta:
    type: File
    inputBinding:
      position: 1
  qc_count:
    type: int
    inputBinding:
        position: 2

baseCommand: [empty_fasta.sh]

outputs:
  fasta_out:
    type: File
    outputBinding:
      glob: "*.fasta"


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
