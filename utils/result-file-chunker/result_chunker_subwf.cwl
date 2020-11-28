#!/usr/bin/env
cwlVersion: v1.2.0-dev2
class: Workflow

requirements:
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_files:
    type:
    - "null"
    - type: array
      items: ["null", "File"]
  format: string
  type_fasta: string?
  size_limit: int?
  line_number_tsv: int?

outputs:
  chunked_by_size_files:
    type: File[]
    outputSource:
      - make_output_flatten/array1d
      - chunking/chunked_file
    linkMerge: merge_flattened
    pickValue: all_non_null

steps:

  chunking:
    run: result_chunker.cwl
    scatter: input_file
    in:
      input_file: input_files
      type_fasta: type_fasta
      format: format
      size_limit: size_limit
      line_number_tsv: line_number_tsv
    out: [ chunked_by_size_files, chunked_file ]

  make_output_flatten:
    run: ../make_flatten.cwl
    in:
      arrayTwoDim: chunking/chunked_by_size_files
    out: [ array1d ]


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
