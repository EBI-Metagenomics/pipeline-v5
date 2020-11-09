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
  input_file: File
  format: string
  type_fasta: string?

outputs:
  chunked_by_size_files:
    type: File[]
    outputSource: gzip_chunks/compressed_file
  chunked_file:
    type: File
    outputSource: create_chunks_file/chunks_file

steps:

  chunking_fasta:
    when: $(inputs.format == 'fasta')
    run: split_fasta.cwl
    in:
      infile: input_file
      type_fasta: type_fasta
      format: format
    out: [ chunks ]

  chunking_tsv:
    when: $(inputs.format == 'tsv')
    run: split_tsv.cwl
    in:
      format: format
      infile: input_file
      line_number: { default: 1000 }
      prefix:
        source: input_file
        valueFrom: "$(self.nameroot)_"
    out: [ chunks ]

  gzip_chunks:
    run: ../pigz/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        source:
          - chunking_tsv/chunks
          - chunking_fasta/chunks
        pickValue: all_non_null
        linkMerge: merge_flattened
    out: [compressed_file]

  create_chunks_file:
    run: create_chunks_file.cwl
    in:
      infile: input_file
      list_chunks: gzip_chunks/compressed_file
    out: [ chunks_file ]


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
