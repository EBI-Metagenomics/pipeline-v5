#!/usr/bin/env cwl-runner
cwlVersion: v1.2
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
    forward_reads: File?
    reverse_reads: File?

    single_reads: File?

    qc_min_length: int
    run_qc: boolean


outputs:

 # hashsum files
  input_files_hashsum_paired:
    type: File[]?
    outputSource: hashsum_paired/hashsum
    pickValue: all_non_null
  input_files_hashsum_single:
    type: File?
    outputSource: hashsum_single/hashsum

  fastp_filtering_json:
    type: File?
    outputSource: overlap_reads/fastp_report

  qc-statistics:
    type: Directory?
    outputSource: qc_stats/output_dir
  qc_summary:
    type: File?
    outputSource: length_filter/stats_summary_file
  qc-status:
    type: File?
    outputSource: QC-FLAG/qc-flag

  filtered_fasta:
    type: File
    outputSource:
      - length_filter/filtered_file
      - convert_trimmed_reads_to_fasta_noqc/fasta
    pickValue: first_non_null

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


# << SeqPrep (only for paired reads) + gunzip for paired and single>>
  overlap_reads:
    label: Paired-end overlapping reads are merged
    run: ../../subworkflows/seqprep-qc-cond-subwf.cwl
    in:
      single_reads: single_reads
      forward_reads: forward_reads
      reverse_reads: reverse_reads
      paired_reads_length_filter: { default: 70 }
      qc: run_qc
    out: [ unzipped_single_reads, count_forward_submitted_reads, fastp_report ]

# ----- QC = TRUE -----

# << Trim and Reformat >>
  trim_quality_control:
    doc: |
      Low quality trimming (low quality ends and sequences with < quality scores
      less than 15 over a 4 nucleotide wide window are removed)
    when: $(inputs.run_qc == true)
    run: ../../../tools/Trimmomatic/Trimmomatic-v0.36-SE.cwl
    in:
      run_qc: run_qc
      reads1: overlap_reads/unzipped_single_reads
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
    when: $(inputs.run_qc == true)
    in:
      run_qc: run_qc
      sequences: trim_quality_control/reads1_trimmed
    out: [ sequences_with_cleaned_headers ]

  #fasta
  convert_trimmed_reads_to_fasta:
    run: ../../../utils/fastq_to_fasta/fastq_to_fasta.cwl
    when: $(inputs.run_qc == true)
    in:
      run_qc: run_qc
      qc: run_qc
      fastq: clean_fasta_headers/sequences_with_cleaned_headers
    out: [ fasta ]


# << QC filtering >>
  length_filter:
    run: ../../../tools/qc-filtering/qc-filtering.cwl
    when: $(inputs.run_qc == true)
    in:
      run_qc: run_qc
      seq_file: convert_trimmed_reads_to_fasta/fasta
      submitted_seq_count: overlap_reads/count_forward_submitted_reads
      stats_file_name: {default: 'qc_summary'}
      min_length: qc_min_length
      input_file_format: { default: 'fasta' }
    out: [ filtered_file, stats_summary_file ]

  count_processed_reads:
    run: ../../../utils/count_fasta.cwl
    when: $(inputs.run_qc == true)
    in:
      run_qc: run_qc
      sequences: length_filter/filtered_file
      number: { default: 1 }
    out: [ count ]

# << QC FLAG >>
  QC-FLAG:
    run: ../../../utils/qc-flag.cwl
    when: $(inputs.run_qc == true)
    in:
      run_qc: run_qc
      qc_count: count_processed_reads/count
    out: [ qc-flag ]

# << QC >>
  qc_stats:
    run: ../../../tools/qc-stats/qc-stats.cwl
    when: $(inputs.run_qc == true)
    in:
      run_qc: run_qc
      QCed_reads: length_filter/filtered_file
      sequence_count: count_processed_reads/count
    out: [ output_dir, summary_out ]


# ----- QC = FALSE -----

  #fastq
  clean_fasta_headers_noqc:
    run: ../../../utils/clean_fasta_headers.cwl
    when: $(inputs.run_qc == false)
    in:
      run_qc: run_qc
      sequences: overlap_reads/unzipped_single_reads
    out: [ sequences_with_cleaned_headers ]

  #fasta
  convert_trimmed_reads_to_fasta_noqc:
    run: ../../../utils/fastq_to_fasta/fastq_to_fasta.cwl
    when: $(inputs.run_qc == false)
    in:
      run_qc: run_qc
      qc: run_qc
      fastq: clean_fasta_headers_noqc/sequences_with_cleaned_headers
    out: [ fasta ]


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
