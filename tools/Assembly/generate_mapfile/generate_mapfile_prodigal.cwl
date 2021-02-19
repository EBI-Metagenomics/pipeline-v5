#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Generate mapfile for digest(seq) and MGYP"

hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.python3:v3.1

requirements:
  ResourceRequirement:
    ramMin: 500
    coresMin: 1
  InlineJavascriptRequirement: {}

baseCommand: [ generate_mapfile_prodigal.py ]

inputs:
  input_fasta:
    format: 'edam:format_1929'
    type: File
    inputBinding:
      separate: true
      prefix: "-i"
  output_name:
    type: string
    inputBinding:
      separate: true
      prefix: "-o"

outputs:
  mapfile:
    type: File
    outputBinding:
      glob: $(inputs.output_name)

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