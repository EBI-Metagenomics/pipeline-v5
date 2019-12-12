#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 200
#  DockerRequirement:
#    dockerPull: alpine:3.9.4

baseCommand: ['sort', '-k2,2']

inputs:
  input_table:
    type: File # Diamond's tabular format.
    inputBinding:
      separate: true
      position: 2

stdout: $(inputs.input_table.nameroot).sorted

outputs:
  output_sorted:
    type: stdout

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2019"
s:author: "Ekaterina Sakharova, Maxim Scheremetjew"
