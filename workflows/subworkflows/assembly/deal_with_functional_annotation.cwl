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
  antismash_geneclusters_txt: File
  rna: File
  cds: File
  go_config: File
  eggnog_orthologs: File
  eggnog_annotations: File
  diamond_header: string
  hmmscan_header: string
  ips_header: string
  output_gff_gz: File
  output_gff_index: File

outputs:
  functional_annotation_folder:
    type: Directory
    outputSource: move_to_functional_annotation_folder/out
  stats:
    type: Directory
    outputSource: write_summaries/stats
  summary_antismash:
    type: File
    outputSource: write_summaries/summary_antismash

steps:

# << GO SUMMARY>>
  go_summary:
    run: ../../../tools/GO-slim/go_summary.cwl
    in:
      InterProScan_results: IPS_table
      config: go_config
      output_name:
        source: fasta
        valueFrom: $(self.nameroot).summary.go
    out: [go_summary, go_summary_slim]

# << PFAM >>
  pfam:
    run: ../../../tools/Pfam-Parse/pfam_annotations.cwl
    in:
      interpro: IPS_table
      outputname:
        source: fasta
        valueFrom: $(self.nameroot).pfam
    out: [annotations]

# << summaries and stats IPS, HMMScan, Pfam >>
  write_summaries:
    run: ../func_summaries.cwl
    in:
       interproscan_annotation: IPS_table
       hmmscan_annotation: hmmscan_table
       pfam_annotation: pfam/annotations
       antismash_gene_clusters: antismash_geneclusters_txt
       rna: rna
       cds: cds
    out: [summary_ips, summary_ko, summary_pfam, summary_antismash, stats]

# add header
  header_addition:
    scatter: [input_table, header]
    scatterMethod: dotproduct
    run: ../../../utils/add_header/add_header.cwl
    in:
      input_table:
        - diamond_table
        - hmmscan_table
        - IPS_table
      header:
        - diamond_header
        - hmmscan_header
        - ips_header
    out: [ output_table ]

# << gzip functional annotation files >>
  compression_func_ann:
    run: ../../../utils/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        source:
          - eggnog_annotations
          - eggnog_orthologs
        linkMerge: merge_flattened
    out: [compressed_file]

# chunking
  chunking_tsv:
    run: ../../../utils/result-file-chunker/result_chunker.cwl
    in:
      infile: header_addition/output_table
      format_file: { default: tsv }
      outdirname: { default: table }
    out: [chunks]

# move FUNCTIONAL-ANNOTATION
  move_to_functional_annotation_folder:
    run: ../../../utils/return_directory.cwl
    in:
      list:
        source:
          - output_gff_gz
          - output_gff_index
          - compression_func_ann/compressed_file
          - write_summaries/summary_ips
          - write_summaries/summary_ko
          - write_summaries/summary_pfam
          - go_summary/go_summary
          - go_summary/go_summary_slim
          - chunking_tsv/chunks
        linkMerge: merge_flattened
      dir_name: { default: functional-annotation }
    out: [ out ]


