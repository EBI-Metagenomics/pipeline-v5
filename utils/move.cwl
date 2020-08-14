#!/usr/bin/env
cwlVersion: v1.0
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 16
    ramMin: 200

# hints:
#   - class: DockerRequirement
#     dockerPull: debian:stable-slim

inputs:
  initial_file:
    type: File
    inputBinding:
      position: 1

  out_file_name:
    type: string
    inputBinding:
      position: 2

baseCommand: [ mv ]

outputs:
  renamed_file:
    type: File
    outputBinding:
      glob: $(inputs.out_file_name)

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
