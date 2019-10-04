#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "gather summary file from InterProScan"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 4768  # just a default, could be lowered

inputs:
  ipr_entry_maps:
    type: File
    inputBinding: { position: 1 }

baseCommand: ['write_ipr_summary.py']

stdout: summary.ipr

outputs:
  ipr_summary: stdout

$namespaces:
 s: http://schema.org/
 iana: https://www.iana.org/assignments/media-types/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"