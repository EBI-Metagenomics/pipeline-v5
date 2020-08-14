#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 200

hints:
  DockerRequirement:
    dockerPull: debian:stable-slim

baseCommand: ['sort', '-k2,2']

inputs:
  input_table:
    format: edam:format_2333
    type: File # Diamond's tabular format.
    inputBinding:
      separate: true
      position: 2

stdout: $(inputs.input_table.nameroot).sorted

outputs:
  output_sorted:
    type: stdout
    format: edam:format_2333

$namespaces:
  s: http://schema.org/
  edam: http://edamontology.org/
$schemas:
 - 'http://edamontology.org/EDAM_1.20.owl'
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2019"
s:author: "Ekaterina Sakharova, Maxim Scheremetjew"
