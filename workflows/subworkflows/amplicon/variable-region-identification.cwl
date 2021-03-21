#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.1

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
label: Identifies targeted variable regions in amplicon sequencing

hints:
  DockerRequirement:
    dockerPull: mgnify/pipeline-v5.python3:latest

inputs:
  infernal_matches:
    type: File
    inputBinding:
      position: 3
  output_dir:
    type: string
    default: variable-region-inference

baseCommand: [ classify_regions.py ]

outputs:
  variable-regions-folder:
    type: Directory?
    outputBinding:
      glob: $(inputs.output_dir)

arguments:
  - position: 1
    prefix: '-d'
    valueFrom: $(inputs.output_dir)
  - position: 2
    prefix: '-o'
    valueFrom: ${return inputs.infernal_matches.basename.split("_")[0]}


requirements:
  - class: InlineJavascriptRequirement

$schemas:
  - http://edamontology.org/EDAM_1.16.owl
  - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: "Tatiana Gurbich"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"