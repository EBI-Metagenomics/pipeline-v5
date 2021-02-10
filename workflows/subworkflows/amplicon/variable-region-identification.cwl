#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2.0-dev2

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
label: Identifies targeted variable regions in amplicon sequencing

hints:
  DockerRequirement:
    dockerPull: mgnify/pipeline-v5.python3:latest

inputs:

baseCommand: [ classify_regions.py ]

outputs:


$namespaces:
  edam: http://edamontology.org/
  iana: https://www.iana.org/assignments/media-types/
  s: http://schema.org/
$schemas:
  - http://edamontology.org/EDAM_1.16.owl
  - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: "Tatiana Gurbich"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:   "EMBL - European Bioinformatics Institute"