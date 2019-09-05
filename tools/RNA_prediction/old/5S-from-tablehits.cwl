#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

inputs:
  table_hits:
    type: File
    label: output of infernal's cmsearch

outputs:
 5S_coordinates:
   type: File
   outputSource: extract_5S_coords/matched_seqs_with_coords

steps:
  grep:
    run: pull-5Ss.cwl
    in: { hits: table_hits }
    out: [ 5Ss ]

  extract_5S_coords:
    run: extract-coords-from-cmsearch.cwl
    in: { infernal_matches: grep/5Ss }
    out: [ matched_seqs_with_coords ]

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
