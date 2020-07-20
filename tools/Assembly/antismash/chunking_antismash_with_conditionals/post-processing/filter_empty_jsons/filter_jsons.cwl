#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "remove empty ({}) jsons from gathering list"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 1000

hints:
  DockerRequirement:
    dockerPull: mgnify/pipeline-v5.python3:latest

inputs:
  input_jsons:
    type: File[]
    inputBinding:
      prefix: -j

baseCommand: [ python3, /Users/kates/Desktop/EBI/CWL/pipeline/pipeline-v5/tools/Assembly/antismash/chunking_antismash_with_conditionals/post-processing/filter_empty_jsons/filter_jsons.py ]

outputs:
  non_empty_jsons:
    type: File[]
    outputBinding:
      glob: "output/*"


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schema.rdf

's:author': 'Ekaterina Sakharova'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"