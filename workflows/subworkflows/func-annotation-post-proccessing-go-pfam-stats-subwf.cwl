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
  go_config: [string?, File?]
  hmmscan_table: File
  diamond_table: File?
  antismash_geneclusters_txt: File?
  rna: File
  cds: File
  ko_file: [string, File]
  diamond_header: string?
  hmmsearch_header: string
  ips_header: string

outputs:
  summary_antismash:
    type: File?
    outputSource: write_summaries/summary_antismash
  stats:
    type: File
    outputSource: write_summaries/stats
  summary_ips:
    type: File
    outputSource: write_summaries/summary_ips
  summary_ko:
    type: File
    outputSource: write_summaries/summary_ko
  summary_pfam:
    type: File
    outputSource: write_summaries/summary_pfam
  go_summary:
    type: File
    outputSource: go_summary_step/go_summary
  go_summary_slim:
    type: File
    outputSource: go_summary_step/go_summary_slim
  chunked_tsvs:
    type: File[]
    outputSource: chunking_tsv/chunked_by_size_files

steps:

# << GO SUMMARY>>
  go_summary_step:
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
    run: func_summaries.cwl
    in:
       interproscan_annotation: IPS_table
       hmmscan_annotation: hmmscan_table
       pfam_annotation: pfam/annotations
       antismash_gene_clusters: antismash_geneclusters_txt
       rna: rna
       cds: cds
       ko_file: ko_file
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
        - hmmsearch_header
        - ips_header
    out: [ output_table ]

# chunking
  chunking_tsv:
    run: ../../../utils/result-file-chunker/result_chunker_subwf.cwl
    in:
      input_files: header_addition/output_table
      format: { default: tsv }
    out: [ chunked_by_size_files ]



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
