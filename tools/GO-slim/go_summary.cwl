#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 4000  # just a default, could be lowered

hints:
 DockerRequirement:
   dockerPull: go_slim:latest
 SoftwareRequirement:
   packages:
     owltools:
       specs: [ "https://identifiers.org/rrid/RRID:SCR_005732" ]
       version: [ "8d53bbce1ffe60d9aa3357c1001599f9a882317a" ]

inputs:
  InterProScan_results:
    type: File
    format: edam:format_3475
    inputBinding:
      prefix: --input-file

  config:
    type: string
    inputBinding:
      prefix: --config

  output_name:
    type: string
    inputBinding:
      prefix: --output-file

baseCommand: ["go_summary_pipeline-1.0.py"]

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

$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"