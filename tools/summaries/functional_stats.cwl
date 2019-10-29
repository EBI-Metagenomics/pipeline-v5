#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "generate all functional stats and orf stats"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 10000  # just a default, could be lowered

inputs:
  interproscan:
    type: File
    inputBinding:
        prefix: -i
  hmmscan:
    type: File
    inputBinding:
        prefix: -k
  pfam:
    type: File
    inputBinding:
        prefix: -p
  cmsearch_file:
    type: File
    inputBinding:
        prefix: -r
  cds_file:
    type: File
    inputBinding:
        prefix: -c

baseCommand: [functional_stats.py]

outputs:
  stats:
    type: Directory
    outputBinding:
        glob: "functional-annotation"
  ips_yaml:
    type: File
    outputBinding:
        glob: "InterProScan*.yaml"
  ko_yaml:
    type: File
    outputBinding:
        glob: "KO*.yaml"
  pfam_yaml:
    type: File
    outputBinding:
        glob: "pfam*.yaml"

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