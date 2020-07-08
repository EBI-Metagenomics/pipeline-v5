#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

label: "remove the last } in json for chunks"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 200  # just a default, could be lowered


hints:
  DockerRequirement:
    dockerPull: 'alpine:3.7'

inputs:
  outputname: string

  input_json:
    type: File
    inputBinding:
      position: 3

baseCommand: [ head ]
arguments: [ "-n", "-1"]

stdout: $(inputs.outputname)

outputs:
  output_json:
    type: stdout

$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

's:author': 'Ekaterina Sakharova'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"

