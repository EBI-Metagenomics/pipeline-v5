#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

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
    forward_reads: File
    reverse_reads: File

    ssu_db: {type: File, secondaryFiles: [.mscluster] }
    lsu_db: {type: File, secondaryFiles: [.mscluster] }
    ssu_tax: File
    lsu_tax: File
    ssu_otus: File
    lsu_otus: File

    rfam_models: File[]
    rfam_model_clans: File

    ssu_label: string
    lsu_label: string
    5s_pattern: string

    unite_db: {type: File, secondaryFiles: [.mscluster] }
    unite_tax: File
    unite_otu_file: File
    unite_label: string
    itsonedb: {type: File, secondaryFiles: [.mscluster] }
    itsonedb_tax: File
    itsonedb_otu_file: File
    itsonedb_label: string

outputs:
# << SeqPrep >>
  result_SeqPrep_step:
    type: File
    outputSource: combine_overlapped_and_unmerged_reads/merged_with_unmerged_reads
  count_submitted_reads:
    type: int
    outputSource: count_submitted_reads/count
# << Trimming >>
  trim_quality_control:
    type: File
    outputSource: trim_quality_control/reads1_trimmed

steps:

# << SeqPrep >>
  overlap_reads:
    label: Paired-end overlapping reads are merged
    run: ../tools/SeqPrep/seqprep.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
    out: [ merged_reads, forward_unmerged_reads, reverse_unmerged_reads ]

  combine_overlapped_and_unmerged_reads:
    run: ../tools/SeqPrep/seqprep-merge.cwl
    in:
      merged_reads: overlap_reads/merged_reads
      forward_unmerged_reads: overlap_reads/forward_unmerged_reads
      reverse_unmerged_reads: overlap_reads/reverse_unmerged_reads
    out: [ merged_with_unmerged_reads ]

  count_submitted_reads:
    run: ../utils/count_fastq.cwl
    in:
      sequences: combine_overlapped_and_unmerged_reads/merged_with_unmerged_reads
    out: [ count ]

# << Trim and Reformat >>
  trim_quality_control:
    doc: |
      Low quality trimming (low quality ends and sequences with < quality scores
      less than 15 over a 4 nucleotide wide window are removed)
    run: ../tools/Trimmomatic/Trimmomatic-v0.36-SE.cwl
    in:
      reads1: combine_overlapped_and_unmerged_reads/merged_with_unmerged_reads
      phred: { default: '33' }
      leading: { default: 3 }
      trailing: { default: 3 }
      end_mode: { default: SE }
      minlen: { default: 100 }
      slidingwindow: { default: '4:15' }
      #  default:
      #    windowSize: 4
      #    requiredQuality: 15
    out: [reads1_trimmed]