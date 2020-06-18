#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2.0-dev2

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}
#  SchemaDefRequirement:
#    types:
#      - $import: ../tools/Trimmomatic/trimmomatic-sliding_window.yaml

inputs:
    forward_reads: File?
    reverse_reads: File?

    single_reads: File?

    qc_min_length: int
    stats_file_name: string

outputs:

 # hashsum files
  input_files_hashsum_paired:
    type: File[]?
    outputSource: hashsum_paired/hashsum
    pickValue: all_non_null
  input_files_hashsum_single:
    type: File?
    outputSource: hashsum_single/hashsum

steps:

# << calculate hashsum >>
  hashsum_paired:
    run: ../../../utils/generate_checksum/generate_checksum.cwl
    when: $(inputs.single == null)
    scatter: input_file
    in:
      single: single_reads
      input_file:
        - forward_reads
        - reverse_reads
    out: [ hashsum ]

  hashsum_single:
    run: ../../../utils/generate_checksum/generate_checksum.cwl
    when: $(inputs.single != null)
    in:
      single: single_reads
      input_file: single_reads
    out: [ hashsum ]


# << SeqPrep >>
  overlap_reads:
    label: Paired-end overlapping reads are merged
    run: ../../../tools/SeqPrep/seqprep.cwl
    when: $(inputs.single == null)
    in:
      single: single_reads
      forward_reads: forward_reads
      reverse_reads: reverse_reads
    out: [ merged_reads, forward_unmerged_reads, reverse_unmerged_reads ]


# run amplicon-single-pipeline
  amplicon-single:
    run: amplicon-single-1.cwl
    in:
      single_reads:
        source:
          - overlap_reads/merged_reads
          - single_reads
        pickValue: first_non_null
      qc_min_length: qc_min_length
      stats_file_name: stats_file_name
    out:
      - filtered_fasta
      - qc-statistics
      - qc_summary
      - qc-status