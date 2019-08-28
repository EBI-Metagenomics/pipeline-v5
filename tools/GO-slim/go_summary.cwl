#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 10240  # just a default, could be lowered
  DockerRequirement:
    dockerPull: go_slim:latest
hints:
 SoftwareRequirement:
   packages:
     owltools:
       specs: [ "https://identifiers.org/rrid/RRID:SCR_005732" ]
       version: [ "8d53bbce1ffe60d9aa3357c1001599f9a882317a" ]

inputs:
  InterProScan_results:
    type: File
    inputBinding:
      prefix: --input-file

  config:
    type: File
    inputBinding:
      prefix: --config

baseCommand: ["go_summary_pipeline-1.0.py"]

arguments:
  - valueFrom: go-summary
    prefix: --output-file

outputs:
  go_summary:
    type: File
    format: iana:text/csv
    outputBinding: { glob: go-summary }
  go_summary_slim:
    type: File
    format: iana:text/csv
    outputBinding: { glob: go-summary_slim }


$namespaces:
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"