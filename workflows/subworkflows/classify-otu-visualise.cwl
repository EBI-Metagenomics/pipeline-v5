#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Run taxonomic classification, create OTU table and krona visualisation"

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  fasta: File
  mapseq_ref: {type: File, secondaryFiles: [.mscluster] }
  mapseq_taxonomy: File
  otu_ref: File
  otu_label:
    type: string
  return_dirname: string
  file_for_prefix: File

outputs:

  out_dir:
    type: Directory
    outputSource: return_output_dir/out

  compressed_fasta_output:
    type: File
    outputSource: compress_fasta/compressed_file

  fasta_output:
    type: File
    outputSource: edit_empty_tax/fasta_out

steps:
  mapseq:
    run: ../../tools/mapseq/mapseq.cwl
    in:
      prefix: file_for_prefix
      sequences: fasta
      database: mapseq_ref
      taxonomy: mapseq_taxonomy
    out: [ classifications ]

  classifications_to_otu_counts:
    run: ../../tools/mapseq2biom/mapseq2biom.cwl
    in:
       otu_table: otu_ref
       label: otu_label
       query: mapseq/classifications
    out: [ otu_tsv, otu_txt ]

  visualize_otu_counts:
    run: ../../tools/krona/krona.cwl
    in:
      otu_counts: classifications_to_otu_counts/otu_txt
    out: [ otu_visualization ]

  edit_empty_tax:
    run: ../../tools/biom-convert/empty_tax.cwl
    in:
      mapseq: mapseq/classifications
      otutable: classifications_to_otu_counts/otu_tsv
      biomtable: classifications_to_otu_counts/otu_txt
      krona: visualize_otu_counts/otu_visualization
      fasta: fasta
    out: [mapseq_out, otu_out, biom_out, krona_out, fasta_out]

  counts_to_hdf5:
    run: ../../tools/biom-convert/biom-convert.cwl
    in:
       biom: edit_empty_tax/otu_out
       hdf5: { default: true }
       table_type: { default: 'OTU table' }
    out: [ result ]

  counts_to_json:
    run: ../../tools/biom-convert/biom-convert.cwl
    in:
       biom: edit_empty_tax/otu_out
       json: { default: true }
       table_type: { default: 'OTU table' }
    out: [ result ]

  compress_mapseq:
    run: ../../utils/gzip.cwl
    in:
      uncompressed_file: edit_empty_tax/mapseq_out
    out: [compressed_file]
    label: "gzip mapseq output"

  compress_fasta:
    run: ../../utils/gzip.cwl
    in:
      uncompressed_file: edit_empty_tax/fasta_out
    out: [compressed_file]
    label: "compressed fasta file, original or empty.fasta"

  return_output_dir:
    run: ../../utils/return_directory.cwl
    in:
      dir_name: return_dirname
      list:
        - compress_mapseq/compressed_file
        - edit_empty_tax/otu_out
        - edit_empty_tax/biom_out
        - edit_empty_tax/krona_out
        - counts_to_hdf5/result
        - counts_to_json/result
    out: [ out ]
    label: "return all files in one folder"

$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/