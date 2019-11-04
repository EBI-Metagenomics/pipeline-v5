#!/usr/bin/env
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ScatterFeatureRequirement: {}
  ShellCommandRequirement: {}


inputs:
  hits:
    type: File
    inputBinding:
        position: 2
  model:
    type:
        type: array
        items: File
    inputBinding:
        position: 3

baseCommand: [pull_ncrnas.sh]

outputs:
  matches:
    type:
      type: array
      items: File
    outputBinding:
      glob: "*.hits"

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"