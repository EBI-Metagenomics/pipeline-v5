#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "generate all functional stats and orf stats"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 10000  # just a default, could be lowered

inputs:
  files:
    type: File[]
    inputBinding:
        prefix: -f
  cmsearch_file:
    type: File
    inputBinding:
        prefix: -r
  cds_file:
    type: File
    inputBinding:
        prefix: -c

baseCommand: ['functional_stats.py']

outputs:
  stats:
    type: File[]
    outputBinding:
        glob: "*.stats"
  yamls:
    type: File[]
    outputBinding:
        glob: "*.yaml"

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.7'


$namespaces:
 s: http://schema.org/
 iana: https://www.iana.org/assignments/media-types/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"