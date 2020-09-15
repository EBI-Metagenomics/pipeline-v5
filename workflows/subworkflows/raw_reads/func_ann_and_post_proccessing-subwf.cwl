#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2.0-dev4

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:

  filtered_fasta: File
  rna_prediction_ncRNA: File

  cgc_results_faa: File
  protein_chunk_size_hmm: int
  protein_chunk_size_IPS: int

  func_ann_names_ips: string
  InterProScan_databases: string
  InterProScan_applications: string[]
  InterProScan_outputFormat: string[]
  ips_header: string

  func_ann_names_hmmer: string
  HMM_gathering_bit_score: boolean
  HMM_omit_alignment: boolean
  HMM_database: string
  hmmsearch_header: string

  go_config: string
  ko_file: string
  type_analysis: string

outputs:
  functional_annotation_folder:
    type: Directory
    outputSource: move_to_functional_annotation_folder/out
  stats:
    outputSource: write_summaries/stats
    type: Directory

steps:

# << FUNCTIONAL ANNOTATION: hmmscan, IPS, eggNOG >>
  functional_annotation:
    run: ../../subworkflows/raw_reads/functional_annotation_raw.cwl
    in:
      CGC_predicted_proteins: cgc_results_faa
      chunk_size_hmm: protein_chunk_size_hmm
      chunk_size_IPS: protein_chunk_size_IPS
      name_ips: func_ann_names_ips
      name_hmmer: func_ann_names_hmmer
      HMM_gathering_bit_score: HMM_gathering_bit_score
      HMM_omit_alignment: HMM_omit_alignment
      HMM_database: HMM_database
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
    out: [ hmm_result, ips_result ]

# << GO SUMMARY>>
  go_summary:
    run: ../../../tools/GO-slim/go_summary.cwl
    in:
      InterProScan_results: functional_annotation/ips_result
      config: go_config
      output_name:
        source: filtered_fasta
        valueFrom: $(self.nameroot).summary.go
    out: [go_summary, go_summary_slim]

# << PFAM >>
  pfam:
    run: ../../../tools/Pfam-Parse/pfam_annotations.cwl
    in:
      interpro: functional_annotation/ips_result
      outputname:
        source: filtered_fasta
        valueFrom: $(self.nameroot).pfam
    out: [annotations]

# << summaries and stats IPS, HMMScan, Pfam >>
  write_summaries:
    run: ../../subworkflows/func_summaries.cwl
    in:
       interproscan_annotation: functional_annotation/ips_result
       hmmscan_annotation: functional_annotation/hmm_result
       pfam_annotation: pfam/annotations
       rna: rna_prediction_ncRNA
       ko_file: ko_file
       cds: cgc_results_faa
       type_analysis: type_analysis
    out: [summary_ips, summary_ko, summary_pfam, stats]

# << ------------- FUNCTIONAL FORMATTING AND CHUNKING ------------ >>

# add header
  header_addition:
    scatter: [input_table, header]
    scatterMethod: dotproduct
    run: ../../../utils/add_header/add_header.cwl
    in:
      input_table:
        - functional_annotation/hmm_result
        - functional_annotation/ips_result
      header:
        - hmmsearch_header
        - ips_header
    out: [ output_table ]

# << chunking TSVs >>
  chunking_tsv:
    run: ../../../utils/result-file-chunker/result_chunker.cwl
    in:
      infile: header_addition/output_table
      format_file: { default: tsv }
      outdirname: { default: table }
    out: [chunks]

# << move to fucntional annotation >>
  move_to_functional_annotation_folder:
    run: ../../../utils/return_directory.cwl
    in:
      file_list:
        source:
          - write_summaries/summary_ips
          - write_summaries/summary_ko
          - write_summaries/summary_pfam
          - go_summary/go_summary
          - go_summary/go_summary_slim
          - chunking_tsv/chunks
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
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
