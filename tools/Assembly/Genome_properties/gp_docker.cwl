#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Genome properties https://genome-properties.readthedocs.io"

requirements:
  DockerRequirement:
    dockerPull: genome_properties:latest
  InlineJavascriptRequirement: {}

baseCommand: ["perl", "/genome-properties/code/scripts/assign_genome_properties.pl"] # <--- for docker

arguments:
  - position: 0
    valueFrom: $(inputs.input_tsv_file.nameroot)
    prefix: '-name'
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
  - position: 5
    valueFrom: "long"
    prefix: "-outfiles"

inputs:
  input_tsv_file:
    type: File
    inputBinding:
      separate: true
      prefix: "-matches"

  flatfiles_path:
    type: string
    inputBinding:
      prefix: "-gpdir"
  GP_txt:
    type: string
    inputBinding:
      prefix: "-gpff"

  out_dir:
    type: string?
    inputBinding:
      prefix: "-outdir"

stdout: stdout.txt
stderr: stderr.txt


outputs:
  stdout: stdout
  stderr: stderr

  table:
    type: File?
    outputBinding:
      glob: "TABLE*$(inputs.input_tsv_file.nameroot)"
  json:
    type: File?
    outputBinding:
      glob: "JSON*$(inputs.input_tsv_file.nameroot)"
  summary:
    type: File?
    outputBinding:
      glob: "SUMMARY*$(inputs.input_tsv_file.nameroot)"
  long:
    type: File?
    outputBinding:
      glob: "LONG*$(inputs.input_tsv_file.nameroot)"

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

's:author': 'Ekaterina Sakharova'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"