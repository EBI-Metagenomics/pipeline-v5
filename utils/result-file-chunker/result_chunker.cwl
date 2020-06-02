#!/usr/bin/env
cwlVersion: v1.0
class: CommandLineTool
requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 1000  # just a default, could be lowered

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.7'

inputs:
  infile:
    type: File[]
    inputBinding:
      prefix: -i
  format_file:
    type: string
    inputBinding:
      prefix: -f
  type_fasta:
    type: string?
    inputBinding:
      prefix: -t
  outdirname:
    type: string
    inputBinding:
      prefix: -o

baseCommand: [run_result_file_chunker.py]

outputs:
  chunks:
    type: File[]
    outputBinding:
      glob: $(inputs.outdirname)/*


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"