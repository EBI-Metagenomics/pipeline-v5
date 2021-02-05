#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Add run and study to database"

requirements:
  ResourceRequirement:
    ramMin: 300
  InlineJavascriptRequirement: {}

inputs:
  study_accession:
    type: string
    inputBinding:
      prefix: -s
  config_db_file:
    type: File
    inputBinding:
      prefix: -c
  run_accession:
    type: string
    inputBinding:
      prefix: -r
  public:
    type: int
    inputBinding:
      prefix: --public

baseCommand: [ add_run.py ]

stderr: stderr.txt
stdout: stdout.txt

outputs:
  logs: stdout


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
