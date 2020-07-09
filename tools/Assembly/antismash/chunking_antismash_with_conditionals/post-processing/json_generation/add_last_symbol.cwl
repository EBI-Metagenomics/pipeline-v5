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
    dockerPull: mgnify/pipeline-v5.bash

inputs:

  input_json:
    type: File
    inputBinding:
      position: 1
  outputname:
    type: string
    inputBinding:
      position: 2
  symbol:
    type: string
    inputBinding:
      position: 3

baseCommand: [ add_symbol_json.sh ]

outputs:
  output_json:
    type: File
    outputBinding:
      glob: $(inputs.outputname)

$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

's:author': 'Ekaterina Sakharova'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"

