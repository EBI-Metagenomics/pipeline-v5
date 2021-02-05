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
  config_db_file:
    type: File
    inputBinding:
      prefix: -c
  run_accession:
    type: string
    inputBinding:
      prefix: -p

baseCommand: [ assign_mgyp_db.py ]

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

  proteins_metadata:
    type: File
    outputBinding:
      glob: "*.peptides.txt"

  stderr_protein_assign:
    type: stderr

hints:
  - class: DockerRequirement
    dockerPull: 'microbiomeinformatics/pipeline-v5.protein_db:v1.0'

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
