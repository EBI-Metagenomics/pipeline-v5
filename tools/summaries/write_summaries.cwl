#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "gather summary file from InterProScan"

requirements:
  ResourceRequirement:
    ramMin: 9500  # just a default, could be lowered

inputs:
  entry_maps:
    type: File[]
    inputBinding:
        position: 0

baseCommand: ['write_summaries.py']

outputs:
  summaries:
    type: array
    items: File
    outputBinding:
        glob: "summary.*"

$namespaces:
 s: http://schema.org/
 iana: https://www.iana.org/assignments/media-types/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
