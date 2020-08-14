#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  - class: ScatterFeatureRequirement

hints:
  DockerRequirement:
    dockerPull: debian:stable-slim

baseCommand: ['sed', '/^#/d; s/ \+/\t/g']

inputs:
  input_table:
    type: File
    inputBinding:
      separate: true
      position: 2

stdout: $(inputs.input_table.nameroot)_tab.tbl

outputs:
  output_with_tabs:
    type: stdout


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"
