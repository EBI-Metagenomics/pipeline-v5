#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "antiSMASH"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 200

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.python3:v1

baseCommand: [ reformat-antismash.py ]

inputs:
  glossary:
    type: [string, File]
    inputBinding:
      position: 1
      prefix: -g
  geneclusters:
    type: File
    inputBinding:
        position: 2
        prefix: -a

outputs:
  reformatted_clusters:
    type: File
    outputBinding:
      glob: geneclusters-summary.txt

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: "Ekaterina Sakharova"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
