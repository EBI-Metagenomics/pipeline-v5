#!/usr/bin/env
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ScatterFeatureRequirement: {}
  ShellCommandRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 200

hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.bash-scripts:v1.3

inputs:
  hits:
    type: File
    inputBinding:
        position: 2
  model:
    type:
        type: array
        items: string
    inputBinding:
        position: 3

baseCommand: [pull_ncrnas.sh]

outputs:
  matches:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.RF*"

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
