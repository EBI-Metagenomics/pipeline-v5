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
  input_files_hashsum:
    type: File[]
    outputSource: hashsum_step/hashsum
    pickValue: all_non_null


steps:

# << calculate hashsum >>
  hashsum_step:
    run: ../../../utils/generate_checksum/generate_checksum.cwl
    scatter: input_file
    in:
      input_file:
        - forward_reads
        - reverse_reads
        - single_reads
    out: [ hashsum ]



