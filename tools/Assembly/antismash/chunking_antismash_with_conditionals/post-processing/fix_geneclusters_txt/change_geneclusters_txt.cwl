#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "change EMBL and GBK files"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 1000

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.python3:v3.1

inputs:
  input_geneclusters_txt:
    type: File
    inputBinding:
      prefix: -i
  output_filename:
    type: string
    inputBinding:
      prefix: -o

baseCommand: [ change_geneclusters_ctg.py ]

outputs:
  fixed_txt:
    type: File
    outputBinding:
      glob: $(inputs.output_filename)

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: "Ekaterina Sakharova"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"