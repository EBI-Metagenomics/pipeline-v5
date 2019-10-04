#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "generate all functional stats and orf stats"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 10000  # just a default, could be lowered

inputs:
  interpro_file:
    type: File
    inputBinding:
        position: 1
        prefix: -i
  hmmscan_file:
    type: File
    inputBinding:
        position: 2
        prefix: -k
  pfam_file:
    type: File
    inputBinding:
        position: 3
        prefix: -p
  cmsearch_file:
    type: File
    inputBinding:
        position: 4
        prefix: -r
  cds_file:
    type: File
    inputBinding:
        position: 5
        prefix: -c

baseCommand: ['functional_stats.py']

outputs:
  ipr_stats:
    type: File
    outputBinding:
        glob: "ipr.stats"
  pfam_stats:
    type: File
    outputBinding:
        glob: "pfam.stats"
  go_stats:
    type: File
    outputBinding:
        glob: "GO.stats"
  hmmscan_stats:
    type: File
    outputBinding:
        glob: "hmmscan.stats"
  ipr_maps:
    type: File
    outputBinding:
        glob: "ipr_entry_maps.yaml"
  orf_stats:
    type: File
    outputBinding:
        glob: "orf.stats"


$namespaces:
 s: http://schema.org/
 iana: https://www.iana.org/assignments/media-types/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"