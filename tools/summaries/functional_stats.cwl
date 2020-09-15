#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "generate all functional stats and orf stats"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 8000  # just a default, could be lowered

inputs:

  type_analysis:
    type: string
    inputBinding:
        prefix: -t
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
    format: edam:format_3475
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
  antismash_file:
    type: File?
    inputBinding:
        prefix: -a
  ko_file:
    type: string
    inputBinding:
        prefix: -ko

baseCommand: [functional_stats.py]

outputs:
  stats:
    type: Directory
    outputBinding:
        glob: "functional-annotation"
  ips_yaml:
    type: File
    format: edam:format_3750
    outputBinding:
        glob: "InterProScan*.yaml"
  ko_yaml:
    type: File
    format: edam:format_3750
    outputBinding:
        glob: "KO*.yaml"
  pfam_yaml:
    type: File
    format: edam:format_3750
    outputBinding:
        glob: "pfam*.yaml"
  antismash_yaml:
    type: File?
    format: edam:format_3750
    outputBinding:
        glob: "antismash*.yaml"

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.7'


$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:   "EMBL - European Bioinformatics Institute"