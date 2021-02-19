#!/usr/bin/env cwl-runner
class: CommandLineTool
cwlVersion: "v1.0"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: 2
    ramMin: 200  # just a default, could be lowered

hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.python3:v3.1

baseCommand: [ count_lines.py ]

inputs:
  sequences:
    type: File
    inputBinding:
      prefix: -f
  number:
    type: int
    inputBinding:
      prefix: -n

outputs:
  count:
    type: int
    outputBinding:
      glob: data.txt
      loadContents: true
      outputEval: $(parseInt(self[0].contents))

$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
