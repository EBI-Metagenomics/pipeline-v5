#!/usr/bin/env
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: 1
    ramMin: 5000

inputs:
  input_file:
    type: File?
    inputBinding:
      position: 1
      prefix: "-i"
    # <<doesn't support by cwltoil>> format: [ edam:format_1929 , edam:format_1930 ]

baseCommand: [ generate_checksum.py ]

outputs:
  hashsum:
    type: File
    outputBinding:
      glob: "*sha1"

hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.python3:v3.1

$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"

