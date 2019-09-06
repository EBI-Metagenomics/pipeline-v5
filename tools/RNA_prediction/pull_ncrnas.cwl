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
    type: File
    inputBinding:
        position: 3

  script:
    type: File
    inputBinding:
        position: 1

baseCommand: [sh]

stdout: $(inputs.model.nameroot).hits  # helps with cwltool's --cache

outputs:
    matches:
        type: stdout

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"