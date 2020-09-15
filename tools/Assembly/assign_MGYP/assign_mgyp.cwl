#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Assign MGYP to protein sequences"

requirements:
  ResourceRequirement:
    ramMin: 300

inputs:
  input_fasta:
    type: File
    inputBinding:
      prefix: -f
  config:
    type: string
    inputBinding:
      prefix: -c
  release:
    type: int
    inputBinding:
      prefix: -r
  accession:
    type: string
    inputBinding:
      prefix: -a
  private:
    type: boolean?
    inputBinding:
      prefix: --private

baseCommand: [ assign_MGYPs.py ]

outputs:
  renamed_proteins:
    type: File
    outputBinding:
        glob: "*_FASTA.mgyp.fasta"

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.7'

$namespaces:
 s: http://schema.org/
 iana: https://www.iana.org/assignments/media-types/
$schemas:
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
