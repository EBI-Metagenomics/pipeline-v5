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
#      - $import: ../tools/biom-convert/biom-convert-table.yaml

inputs:
    single_reads: File
    forward_unmerged_reads: File?
    reverse_unmerged_reads: File?

    qc_min_length: int

    ssu_db: {type: File, secondaryFiles: [.mscluster] }
    lsu_db: {type: File, secondaryFiles: [.mscluster] }
    ssu_tax: File
    lsu_tax: File
    ssu_otus: File
    lsu_otus: File

    rfam_models: File[]
    rfam_model_clans: File
    other_ncRNA_models: string[]

    ssu_label: string
    lsu_label: string
    5s_pattern: string
    5.8s_pattern: string

    # cgc
    CGC_config: File
    CGC_postfixes: string[]
    cgc_chunk_size: int

    # functional annotation
    fa_chunk_size: int
    func_ann_names_ips: string
    func_ann_names_hmmscan: string
    HMMSCAN_gathering_bit_score: boolean
    HMMSCAN_omit_alignment: boolean
    HMMSCAN_name_database: string
    HMMSCAN_data: Directory
    hmmscan_header: string
    EggNOG_db: File?
    EggNOG_diamond_db: File?
    EggNOG_data_dir: string?
    InterProScan_databases: Directory
    InterProScan_applications: string[]  # ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
    InterProScan_outputFormat: string[]  # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?
    ips_header: string

    # GO
    go_config: File

outputs:

  qc-statistics:
    type: Directory
    outputSource: qc_stats/output_dir
  qc_summary:
    type: File
    outputSource: length_filter/stats_summary_file
  qc-status:
    type: File
    outputSource: QC-FLAG/qc-flag

  motus_output:
    type: File
    outputSource: motus_taxonomy/motus

  filtered_fasta:
    type: File
    outputSource: length_filter/filtered_file


steps:

# << unzipping only >>
  unzip_reads:
    run: ../../../utils/multiple-gunzip.cwl
    in:
      target_reads: single_reads
      forward_unmerged_reads: forward_unmerged_reads
      reverse_unmerged_reads: reverse_unmerged_reads
      reads: { default: true }
    out: [ unzipped_merged_reads ]

  count_submitted_reads:
    run: ../../../utils/count_fastq.cwl
    in:
      sequences: unzip_reads/unzipped_merged_reads
    out: [ count ]

# << mOTUs2 >>
  motus_taxonomy:
    run: ../../subworkflows/raw_reads/mOTUs-workflow.cwl
    in:
      reads: unzip_reads/unzipped_merged_reads
    out: [ motus ]

# << Trim and Reformat >>
  trimming:
    run: ../../subworkflows/trim_and_reformat_reads.cwl
    in:
      reads: unzip_reads/unzipped_merged_reads
    out: [ trimmed_and_reformatted_reads ]

# << QC filtering >>
  length_filter:
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
      sequences: length_filter/filtered_file
    out: [ count ]

# << QC FLAG >>
  QC-FLAG:
    run: ../../../utils/qc-flag.cwl
    in:
        qc_count: count_processed_reads/count
    out: [ qc-flag ]

# << deal with empty fasta files >>
  validate_fasta:
    run: ../../../utils/empty_fasta.cwl
    in:
        fasta: length_filter/filtered_file
        qc_count: count_processed_reads/count
    out: [ fasta_out ]

# << QC >>
  qc_stats:
    run: ../../../tools/qc-stats/qc-stats.cwl
    in:
        QCed_reads: validate_fasta/fasta_out
        sequence_count: count_processed_reads/count
    out: [ output_dir, summary_out ]