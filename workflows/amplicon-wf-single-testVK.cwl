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
    stats_file_name: string

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
    5.8s_pattern: string

    unite_db: {type: File, secondaryFiles: [.mscluster] }
    unite_tax: File
    unite_otu_file: File
    unite_label: string
    itsonedb: {type: File, secondaryFiles: [.mscluster] }
    itsonedb_tax: File
    itsonedb_otu_file: File
    itsonedb_label: string

outputs:

  gz_files:  # fasta.gz, cmsearch.gz, deoverlapped.gz
    type: File[]
    outputSource: gzip_files/compressed_file

  qc-statistics:
    type: Directory
    outputSource: qc_stats/output_dir
  qc_summary:
    type: File
    outputSource: run_quality_control_filtering/stats_summary_file

  LSU_folder:
    type: Directory
    outputSource: classify/LSU_folder
  SSU_folder:
    type: Directory
    outputSource: classify/SSU_folder

  sequence-categorisation_folder:
    type: Directory
    outputSource: classify/sequence-categorisation

  sequence-categorisation_folder_two:
    type: Directory
    outputSource: classify/sequence-categorisation_two

  sequence-categorisation_masking:
    type: Directory
    outputSource: ITS/masking_file

  ITS_unite_results:
    type: Directory
    outputSource: ITS/unite_folder

  ITS_itsonedb_results:
    type: Directory
    outputSource: ITS/itsonedb_folder

  rna-count:
    type: File
    outputSource: classify/LSU-SSU-count

  qc-status:
    type: File
    outputSource: QC-FLAG/qc-flag

steps:

# << unzipping only >>
  unzip_reads:
    run: ../utils/multiple-gunzip.cwl
    in:
      target_reads: single_reads
      forward_unmerged_reads: forward_unmerged_reads
      reverse_unmerged_reads: reverse_unmerged_reads
      reads: { default: true }
    out: [ unzipped_merged_reads ]

  count_submitted_reads:
    run: ../utils/count_fastq.cwl
    in:
      sequences: unzip_reads/unzipped_merged_reads
    out: [ count ]

# << Trim and Reformat >>
  trimming:
    run: subworkflows/trim_and_reformat_reads.cwl
    in:
      reads: unzip_reads/unzipped_merged_reads
    out: [ trimmed_and_reformatted_reads ]

# << QC filtering >>
  run_quality_control_filtering:
    run: ../tools/qc-filtering/qc-filtering.cwl
    in:
      seq_file: trimming/trimmed_and_reformatted_reads
      submitted_seq_count: count_submitted_reads/count
      stats_file_name: {default: 'qc_summary'}
      min_length: qc_min_length
      input_file_format: { default: 'fasta' }
    out: [ filtered_file, stats_summary_file ]

  count_processed_reads:
    run: ../utils/count_fasta.cwl
    in:
      sequences: run_quality_control_filtering/filtered_file
    out: [ count ]

# << QC FLAG >>
  QC-FLAG:
    run: ../utils/qc-flag.cwl
    in:
        qc_count: count_processed_reads/count
    out: [ qc-flag ]

# << deal with empty fasta files >>
  validate_fasta:
    run: ../utils/empty_fasta.cwl
    in:
        fasta: run_quality_control_filtering/filtered_file
        qc_count: count_processed_reads/count
    out: [ fasta_out ]

# << QC >>
  qc_stats:
    run: ../tools/qc-stats/qc-stats.cwl
    in:
        QCed_reads: validate_fasta/fasta_out
        sequence_count: count_processed_reads/count
    out: [ output_dir, summary_out ]

# << Get RNA >>
  classify:
    run: subworkflows/rna_prediction-sub-wf.cwl
    in:
      input_sequences: validate_fasta/fasta_out
      silva_ssu_database: ssu_db
      silva_lsu_database: lsu_db
      silva_ssu_taxonomy: ssu_tax
      silva_lsu_taxonomy: lsu_tax
      silva_ssu_otus: ssu_otus
      silva_lsu_otus: lsu_otus
      ncRNA_ribosomal_models: rfam_models
      ncRNA_ribosomal_model_clans: rfam_model_clans
      pattern_SSU: ssu_label
      pattern_LSU: lsu_label
      pattern_5S: 5s_pattern
      pattern_5.8S: 5.8s_pattern
    out:
      - ncRNA
      - cmsearch_result
      - LSU-SSU-count
      - SSU_folder
      - LSU_folder
      - sequence-categorisation
      - sequence-categorisation_two
      - SSU_coords
      - LSU_coords

# << ITS >>
  ITS:
    run: subworkflows/ITS/ITS-wf.cwl
    in:
      query_sequences: validate_fasta/fasta_out
      LSU_coordinates: classify/LSU_coords
      SSU_coordinates: classify/SSU_coords
      unite_database: unite_db
      unite_taxonomy: unite_tax
      unite_otus: unite_otu_file
      itsone_database: itsonedb
      itsone_taxonomy: itsonedb_tax
      itsone_otus: itsonedb_otu_file
      otu_unite_label: unite_label
      otu_itsone_label: itsonedb_label
    out:
      - masking_file
      - unite_folder
      - itsonedb_folder

# gzip and chunk
  gzip_files:
    run: ../utils/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        - validate_fasta/fasta_out
        - classify/cmsearch_result
        - classify/ncRNA
    out: [compressed_file]