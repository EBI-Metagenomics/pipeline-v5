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
  embl_file:
    type: File
    inputBinding:
      prefix: -i
  gbk_filename:
    type: string
    inputBinding:
      prefix: -g
  embl_filename:
    type: string
    inputBinding:
      prefix: -e
  names_table:
    type: File
    inputBinding:
      prefix: -t

baseCommand: [ change_antismash_output.py ]

outputs:
  fixed_embl:
    type: File
    outputBinding:
      glob: $(inputs.embl_filename)
  fixed_gbk:
    type: File
    outputBinding:
      glob: $(inputs.gbk_filename)


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