#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "gather summary file from InterProScan"

requirements:
  ResourceRequirement:
    ramMin: 9500  # just a default, could be lowered

inputs:
  ipr_entry_maps:
    type: File
    inputBinding:
        position: 1
        prefix: -i

  hmm_entry_maps:
    type: File
    inputBinding:
        position: 2
        prefix: -k

  pfam_entry_maps:
    type: File
    inputBinding:
        position: 3
        prefix: -p

baseCommand: ['write_ipr_summary.py']

outputs:
  ipr_summary:
    type: File
    outputBinding:
        glob: "summary.ipr"

  hmm_summary:
    type: File
    outputBinding:
        glob: "summary.hmm"

  pfam_summary:
    type: File
    outputBinding:
        glob: "summary.pfam"


$namespaces:
 s: http://schema.org/
 iana: https://www.iana.org/assignments/media-types/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"