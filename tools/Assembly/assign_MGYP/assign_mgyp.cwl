#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Assign MGYP to protein sequences"

requirements:
  ResourceRequirement:
    ramMin: 15000
  InlineJavascriptRequirement: {}

inputs:
  input_fasta:
    type: File
    inputBinding:
      prefix: -f
  config:
    type: string
    inputBinding:
      prefix: -c
  release:
    type: string
    inputBinding:
      prefix: -r
  accession:
    type: string
    inputBinding:
      prefix: -a
  private:
    type: boolean?
    inputBinding:
      prefix: --private

baseCommand: [ assign_MGYPs.py ]

stderr: stderr.txt

outputs:
  renamed_proteins:
    type: File
    format: edam:format_1929
    outputBinding:
      glob: "*.mgyp.fasta"
      outputEval: |
        ${
          self[0].basename = inputs.input_fasta.nameroot + '.faa';
          return self[0]
        }
  stderr_protein_assign:
    type: stderr

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.7'

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
