#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "gather summary file from InterProScan"

requirements:
  ResourceRequirement:
    ramMin: 9500  # just a default, could be lowered

inputs:
  ips_entry_maps:
    type: File
    inputBinding:
      prefix: -i
  ips_outname:
    type: string
    inputBinding:
      prefix: --ips-name

  ko_entry_maps:
    type: File
    inputBinding:
      prefix: -k
  ko_outname:
    type: string
    inputBinding:
      prefix: --ko-name

  pfam_entry_maps:
    type: File
    inputBinding:
      prefix: -p
  pfam_outname:
    type: string
    inputBinding:
      prefix: --pfam-name

baseCommand: [write_summaries.py]

outputs:
  summaries:
    type: File[]
    outputBinding:
        glob: "*summary.*"

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
