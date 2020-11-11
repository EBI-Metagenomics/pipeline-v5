#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 4000  # just a default, could be lowered

hints:
 DockerRequirement:
   dockerPull: microbiomeinformatics/pipeline-v5.go-summary:v1.0
 SoftwareRequirement:
   packages:
     owltools:
       specs: [ "https://identifiers.org/rrid/RRID:SCR_005732" ]
       version: [ "8d53bbce1ffe60d9aa3357c1001599f9a882317a" ]

baseCommand: [ "go_summary_pipeline-1.0.py" ]

inputs:
  InterProScan_results:
    type: File
    format: edam:format_3475
    inputBinding:
      prefix: --input-file

  config:
    type: [string?, File?]
    inputBinding:
      prefix: --config
    default: "/tools/go_summary-config.json"

  output_name:
    type: string

arguments:
  - "--output-file"
  - $(inputs.output_name)

stderr: stderr.txt
stdout: stdout.txt

outputs:
  go_summary:
    type: File
    format: edam:format_3752
    outputBinding:
      glob: "*.go"
  go_summary_slim:
    type: File
    format: edam:format_3752
    outputBinding:
      glob: "*.go_slim"
  stderr: stderr
  stdout: stdout

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