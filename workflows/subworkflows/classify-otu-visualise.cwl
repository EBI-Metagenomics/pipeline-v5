#!/usr/bin/env cwl-runner

cwlVersion: v1.2.0-dev4
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
  mapseq_ref:
    type: File
    secondaryFiles: [.mscluster]
  mapseq_taxonomy: [string, File]
  otu_ref: [string, File]
  otu_label:
    type: string
  return_dirname: string
  file_for_prefix: File

outputs:

  out_dir:
    type: Directory?
    outputSource: return_output_dir/out

  compressed_fasta_output:
    type: File
    outputSource: compress_fasta/compressed_file


steps:
  compress_fasta:
    run: ../../utils/pigz/gzip.cwl
    in:
      uncompressed_file: fasta
    out: [ compressed_file ]
    label: "compressed fasta file"

  mapseq:
    run: ../../tools/RNA_prediction/mapseq/mapseq.cwl
    in:
      prefix: file_for_prefix
      sequences: fasta
      database: mapseq_ref
      taxonomy: mapseq_taxonomy
    out: [ classifications ]

  compress_mapseq:
    run: ../../utils/pigz/gzip.cwl
    in:
      uncompressed_file: mapseq/classifications
    out: [ compressed_file ]
    label: "gzip mapseq output"

  classifications_to_otu_counts:
    run: ../../tools/RNA_prediction/mapseq2biom/mapseq2biom.cwl
    in:
       otu_table: otu_ref
       label: otu_label
       query: mapseq/classifications
       taxid_flag: { default: true }
    out: [ otu_tsv, otu_txt, otu_tsv_notaxid ]

  visualize_otu_counts:
    run: ../../tools/RNA_prediction/krona/krona.cwl
    in:
      otu_counts: classifications_to_otu_counts/otu_txt
    out: [ otu_visualization ]

  count_lines_mapseq:
    run: ../../utils/count_number_lines.cwl
    in:
      input_file: mapseq/classifications
    out: [ number ]

# if mapseq output has more than 2 lines - return folder, else return null

  counts_to_hdf5:
    when: $(inputs.count > 2)
    run: ../../tools/RNA_prediction/biom-convert/biom-convert.cwl
    in:
       count: count_lines_mapseq/number
       biom: classifications_to_otu_counts/otu_tsv_notaxid
       hdf5: { default: true }
       table_type: { default: 'OTU table' }
    out: [ result ]

  counts_to_json:
    when: $(inputs.count > 2)
    run: ../../tools/RNA_prediction/biom-convert/biom-convert.cwl
    in:
       count: count_lines_mapseq/number
       biom: classifications_to_otu_counts/otu_tsv_notaxid
       json: { default: true }
       table_type: { default: 'OTU table' }
    out: [ result ]

  return_output_dir:
    when: $(inputs.count > 2)
    run: ../../utils/return_directory.cwl
    in:
      count: count_lines_mapseq/number
      dir_name: return_dirname
      file_list:
        - compress_mapseq/compressed_file
        - classifications_to_otu_counts/otu_tsv
        - classifications_to_otu_counts/otu_txt
        - visualize_otu_counts/otu_visualization
        - counts_to_hdf5/result
        - counts_to_json/result
    out: [ out ]
    label: "return all files in one folder"


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
