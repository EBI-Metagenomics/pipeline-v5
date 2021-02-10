#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: v1.2

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
label: Identifies targeted variable regions in amplicon sequencing

#hints:
#  DockerRequirement:
#    dockerPull: mgnify/pipeline-v5.python3:latest

inputs:
  infernal_matches:
    type: File
    inputBinding:
      position: 2

#baseCommand: [ classify_regions.py ]
baseCommand: ["python3", "/Users/Tanya/Desktop/EBI-Metagenomics/elixir-biohackathon/classify_regions.py"]

outputs:
  variable-regions-summary:
    type: File?
    outputBinding:
      glob: $(inputs.infernal_matches.basename).tsv
    format: edam:format_3475

arguments:
  - position: 1
    prefix: '-o'
    valueFrom: $(inputs.infernal_matches.basename)

$schemas:
  - http://edamontology.org/EDAM_1.16.owl
  - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: "Tatiana Gurbich"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"