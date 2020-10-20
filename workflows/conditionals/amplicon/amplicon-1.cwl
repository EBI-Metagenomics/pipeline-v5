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

  qc-statistics:
    type: Directory
    outputSource: qc_stats/output_dir
  qc_summary:
    type: File
    outputSource: run_quality_control_filtering/stats_summary_file

  qc-status:
    type: File
    outputSource: QC-FLAG/qc-flag

  filtered_fasta:
    type: File
    outputSource: run_quality_control_filtering/filtered_file

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

  count_submitted_reads:
    run: ../../../utils/count_lines/count_lines.cwl
    in:
      sequences: overlap_reads/unzipped_single_reads
      number: { default: 4 }
    out: [ count ]

# << SeqPrep (only for paired reads) + gunzip for paired and single>>
  overlap_reads:
    label: Paired-end overlapping reads are merged
    run: ../../subworkflows/seqprep-subwf.cwl
    in:
      single_reads: single_reads
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      paired_reads_length_filter: { default: 70 }
    out: [ unzipped_single_reads ]

# << Trim and Reformat >>
  trimming:
    run: ../../subworkflows/trim_and_reformat_reads.cwl
    in:
      reads: overlap_reads/unzipped_single_reads
      count: count_submitted_reads/count
    out: [ trimmed_and_reformatted_reads ]

# << QC filtering >>
  run_quality_control_filtering:
    run: ../../../tools/qc-filtering/qc-filtering.cwl
    in:
      seq_file: trimming/trimmed_and_reformatted_reads
      submitted_seq_count: count_submitted_reads/count
      stats_file_name: {default: 'qc_summary'}
      min_length: qc_min_length
      input_file_format: { default: 'fasta' }
    out: [ filtered_file, stats_summary_file ]

  count_processed_reads:
    run: ../../../utils/count_fasta.cwl
    in:
      sequences: run_quality_control_filtering/filtered_file
      number: { default: 1 }
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
        QCed_reads: run_quality_control_filtering/filtered_file
        sequence_count: count_processed_reads/count
    out: [ output_dir, summary_out ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
