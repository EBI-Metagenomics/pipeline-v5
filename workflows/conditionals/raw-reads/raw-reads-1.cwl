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


outputs:

 # hashsum files
  input_files_hashsum_paired:
    type: File[]?
    outputSource: hashsum_paired/hashsum
    pickValue: all_non_null
  input_files_hashsum_single:
    type: File?
    outputSource: hashsum_single/hashsum

  qc-statistics:
    type: Directory
    outputSource: qc_stats/output_dir
  qc_summary:
    type: File
    outputSource: length_filter/stats_summary_file
  qc-status:
    type: File
    outputSource: QC-FLAG/qc-flag

  filtered_fasta:
    type: File
    outputSource: length_filter/filtered_file
  motus_input:
    type: File
    outputSource: clean_fasta_headers/sequences_with_cleaned_headers

steps:

# << calculate hashsum >>
  hashsum_paired:
    run: ../../../utils/generate_checksum/generate_checksum.cwl
    when: $(inputs.single == undefined)
    scatter: input_file
    in:
      single: single_reads
      input_file:
        - forward_reads
        - reverse_reads
    out: [ hashsum ]

  hashsum_single:
    run: ../../../utils/generate_checksum/generate_checksum.cwl
    when: $(inputs.single != undefined)
    in:
      single: single_reads
      input_file: single_reads
    out: [ hashsum ]


# << SeqPrep only for paired reads >>
  overlap_reads:
    label: Paired-end overlapping reads are merged
    run: ../../../tools/SeqPrep/seqprep.cwl
    when: $(inputs.single == undefined)
    in:
      single: single_reads
      forward_reads: forward_reads
      reverse_reads: reverse_reads
    out: [ merged_reads, forward_unmerged_reads, reverse_unmerged_reads ]

# << unzipping only >>
  unzip_reads:
    run: ../../../utils/multiple-gunzip.cwl
    in:
      target_reads:
        source:
          - overlap_reads/merged_reads
          - single_reads
        pickValue: first_non_null
      reads: { default: true }
    out: [ unzipped_merged_reads ]

  count_submitted_reads:
    run: ../../../utils/count_fastq/count_fastq.cwl
    in:
      sequences: unzip_reads/unzipped_merged_reads
    out: [ count ]

# << Trim and Reformat >>
  trim_quality_control:
    doc: |
      Low quality trimming (low quality ends and sequences with < quality scores
      less than 15 over a 4 nucleotide wide window are removed)
    run: ../../../tools/Trimmomatic/Trimmomatic-v0.36-SE.cwl
    in:
      reads1: unzip_reads/unzipped_merged_reads
      phred: { default: '33' }
      leading: { default: 3 }
      trailing: { default: 3 }
      end_mode: { default: SE }
      minlen: { default: 100 }
      slidingwindow: { default: '4:15' }
    out: [reads1_trimmed]

  #fastq
  clean_fasta_headers:
    run: ../../../utils/clean_fasta_headers.cwl
    in:
      sequences: trim_quality_control/reads1_trimmed
    out: [ sequences_with_cleaned_headers ]

  #fasta
  convert_trimmed_reads_to_fasta:
    run: ../../../utils/fastq_to_fasta/fastq_to_fasta.cwl
    in:
      fastq: clean_fasta_headers/sequences_with_cleaned_headers
    out: [ fasta ]


# << QC filtering >>
  length_filter:
    run: ../../../tools/qc-filtering/qc-filtering.cwl
    in:
      seq_file: convert_trimmed_reads_to_fasta/fasta
      submitted_seq_count: count_submitted_reads/count
      stats_file_name: {default: 'qc_summary'}
      min_length: qc_min_length
      input_file_format: { default: 'fasta' }
    out: [ filtered_file, stats_summary_file ]

  count_processed_reads:
    run: ../../../utils/count_fasta.cwl
    in:
      sequences: length_filter/filtered_file
    out: [ count ]

# << QC FLAG >>
  QC-FLAG:
    run: ../../../utils/qc-flag.cwl
    in:
        qc_count: count_processed_reads/count
    out: [ qc-flag ]

# << QC >>
  qc_stats:
    run: ../../../tools/qc-stats/qc-stats.cwl
    in:
        QCed_reads: length_filter/filtered_file
        sequence_count: count_processed_reads/count
    out: [ output_dir, summary_out ]
