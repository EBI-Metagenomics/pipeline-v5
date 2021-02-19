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
    format: edam:format_3750
    inputBinding:
      prefix: -i
  ips_outname:
    type: string
    inputBinding:
      prefix: --ips-name

  ko_entry_maps:
    type: File
    format: edam:format_3750
    inputBinding:
      prefix: -k
  ko_outname:
    type: string
    inputBinding:
      prefix: --ko-name

  pfam_entry_maps:
    type: File
    format: edam:format_3750
    inputBinding:
      prefix: -p
  pfam_outname:
    type: string
    inputBinding:
      prefix: --pfam-name

  antismash_entry_maps:
    type: File?
    format: edam:format_3750
    inputBinding:
        prefix: -a
  antismash_outname:
    type: string?
    inputBinding:
        prefix: --antismash-name

baseCommand: [write_summaries.py]

outputs:
  summary_ips:
    type: File
    outputBinding:
        glob: "*summary.ips"
  summary_ko:
    type: File
    outputBinding:
        glob: "*summary.ko"
  summary_pfam:
    type: File
    outputBinding:
        glob: "*summary.pfam"
  summary_antismash:
    type: File?
    outputBinding:
        glob: "*summary.antismash"

hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.python3:v3.1

$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:   "EMBL - European Bioinformatics Institute"