#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  fasta: File
  IPS_table: File
  diamond_table: File
  hmmscan_table: File
  antismash_geneclusters_txt: File?
  rna: File
  cds: File
  go_config: [string?, File?]
  eggnog_orthologs: File
  eggnog_annotations: File
  output_gff_gz: File
  output_gff_index: File
  ko_file: [string, File]
  diamond_header: string
  hmmsearch_header: string
  ips_header: string

outputs:
  functional_annotation_folder:
    type: Directory
    outputSource: move_to_functional_annotation_folder/out
  stats:
    type: Directory
    outputSource: post_processing/stats
  summary_antismash:
    type: File?
    outputSource: post_processing/summary_antismash

steps:

# GO SUMMARY; PFAM; summaries and stats IPS, HMMScan, Pfam; add header; chunking TSV
  post_processing:
    run: ../functional-annotation/post-proccessing-go-pfam-stats-subwf.cwl
    in:
      fasta: fasta
      IPS_table: IPS_table
      go_config: go_config
      hmmscan_table: hmmscan_table
      diamond_table: diamond_table
      antismash_geneclusters_txt: antismash_geneclusters_txt
      rna: rna
      cds: cds
      ko_file: ko_file
      diamond_header: diamond_header
      hmmsearch_header: hmmsearch_header
      ips_header: ips_header
    out:
      - stats
      - summary_antismash
      - summary_pfam
      - summary_ko
      - summary_ips
      - go_summary
      - go_summary_slim
      - chunked_tsvs


# << gzip functional annotation files >>
  compression_func_ann:
    run: ../../../utils/pigz/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        source:
          - eggnog_annotations
          - eggnog_orthologs
        linkMerge: merge_flattened
    out: [compressed_file]


# move FUNCTIONAL-ANNOTATION
  move_to_functional_annotation_folder:
    run: ../../../utils/return_directory/return_directory.cwl
    in:
      file_list:
        source:
          - output_gff_gz
          - output_gff_index
          - compression_func_ann/compressed_file
          - post_processing/summary_ips
          - post_processing/summary_ko
          - post_processing/summary_pfam
          - post_processing/go_summary
          - post_processing/go_summary_slim
          - post_processing/chunked_tsvs
        linkMerge: merge_flattened
      dir_name: { default: functional-annotation }
    out: [ out ]


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
