#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

label: "Calculate completeness of all KEGG pathways"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 300

hints:
  DockerRequirement:
    dockerPull: kegg_pathways:latest

baseCommand: [give_pathways.py]

inputs:
  input_table:
    format: edam:format_3475  # TXT
    type: File
    inputBinding:
      separate: true
      prefix: -i
  graphs:
    type: File
    inputBinding:
      prefix: -g
  pathways_names:
    type: File
    inputBinding:
      prefix: -n
  pathways_classes:
    type: File
    inputBinding:
      prefix: -c
  outputname:
    type: string
    inputBinding:
      prefix: -o

stdout: stdout.txt

outputs:
  summary_pathways:
    type: File
    format: edam:format_3475  # TXT
    outputBinding:
      glob: "*summary.kegg_pathways*"

  summary_contigs:
    type: File
    format: edam:format_3475  # TXT
    outputBinding:
      glob: "*summary.kegg_contigs*"

  stdout: stdout


$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf
's:author': 'Ekaterina Sakharova'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"