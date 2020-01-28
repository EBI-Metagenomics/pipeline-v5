#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

label: "Change random number of whitespaces between columns to tab"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 200

hints:
  DockerRequirement:
    dockerPull: alpine:3.9.4

baseCommand: ['sed', '/^#/d; s/ \+/\t/g']

inputs:
  input_table:
    type: File
    format: edam:format_3475  # TXT
    inputBinding:
      separate: true
      position: 2

stdout: $(inputs.input_table.nameroot)_tab.tbl

outputs:
  output_with_tabs:
    type: stdout
    format: edam:format_3475  # TXT

$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:author': 'Ekaterina Sakharova'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"