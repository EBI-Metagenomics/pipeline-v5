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
    dockerPull: debian:stable-slim

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
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: "Ekaterina Sakharova"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"