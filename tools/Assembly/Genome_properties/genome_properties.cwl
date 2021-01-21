#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Genome properties https://genome-properties.readthedocs.io"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 500

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.genome-properties:v2.0.1

baseCommand: [ assign_genome_properties.pl ] # without docker

arguments:
  - position: 1
    valueFrom: "-all"
  - position: 2
    valueFrom: "table"
    prefix: "-outfiles"
  - position: 4
    valueFrom: "summary"
    prefix: "-outfiles"
  - position: 3
    valueFrom: "web_json"
    prefix: "-outfiles"

inputs:
  input_tsv_file:
    type: File
    format: edam:format_3475
    inputBinding:
      separate: true
      prefix: "-matches"

  flatfiles_path:
    type: [ string?, Directory? ]
    inputBinding:
      prefix: "-gpdir"
    default: "/genome-properties/flatfiles"
  GP_txt:
    type: string?
    inputBinding:
      prefix: "-gpff"
    default: "genomeProperties.txt"

  out_dir:
    type: string?
    inputBinding:
      prefix: "-outdir"
  name:
    type: string?
    inputBinding:
      prefix: "-name"

stdout: stdout.txt
stderr: stderr.txt


outputs:
  stdout: stdout
  stderr: stderr

  table:
    type: File?
    format: edam:format_3475
    outputBinding:
      glob: "TABLE*$(inputs.name)"
  json:
    type: File?
    format: edam:format_3464
    outputBinding:
      glob: "JSON*$(inputs.name)"
  summary:
    type: File
    format: edam:format_3475
    outputBinding:
      glob: "SUMMARY*$(inputs.name)"

$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

s:author: "Ekaterina Sakharova"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
