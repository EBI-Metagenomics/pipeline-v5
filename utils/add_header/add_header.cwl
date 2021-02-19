#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.bash-scripts:v1.3

requirements:
  ResourceRequirement:
    ramMin: 200
    coresMin: 8
  InlineJavascriptRequirement: {}

baseCommand: [ add_header ]

inputs:
  input_table:
    #format: [edam:format_3475, edam:format_2333]
    type: File
    inputBinding:
      prefix: -i
  header:
    type: string
    inputBinding:
      prefix: -h

stdout: $(inputs.input_table.nameroot)

outputs:
  output_table:
    type: stdout
    format: ${if ("format" in inputs.input_table) return inputs.input_table.format; else return 'undefined'}


$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
