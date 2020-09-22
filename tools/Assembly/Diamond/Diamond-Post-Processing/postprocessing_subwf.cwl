#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

doc: |
  Represents a 2 step workflow which retrieves the top hits from a Diamond tabular output file and maps those hits to
  a few UniRef90 annotations, like NCBI tax id or RepID.

label: Represents a post processing step of the Diamond results.

requirements:
  SubworkflowFeatureRequirement: {}

inputs:
  input_diamond: File
  input_db: [string, File]
  filename: string

outputs:
  join_out:
    outputSource: join/output_join
    type: File

steps:
  sorting:
    in:
      input_table: input_diamond
    out:
      - output_sorted
    run: diamond_sorting.cwl

  join:
    in:
      input_diamond: sorting/output_sorted
      input_db: input_db
      filename: filename
    out:
      - output_join
    run: diamond_join.cwl

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2019"
s:author: "Ekaterina Sakharova, Maxim Scheremetjew"