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
    other_ncRNA_name: string

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
    outputSource: run_quality_control_filtering/stats_summary_file
  qc-status:
    type: File
    outputSource: QC-FLAG/qc-flag

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
  ncrnas_folder:
    type: Directory
    outputSource: other_ncrnas/ncrnas

  rna-count:
    type: File
    outputSource: classify/LSU-SSU-count

  motus_output:
    type: File
    outputSource: motus_taxonomy/motus

  compressed_files:
    type: File[]
    outputSource: compression/compressed_file

  functional_annotation_folder:
    type: Directory
    outputSource: move_to_functional_annotation_folder/out
  stats:
    outputSource: write_summaries/stats
    type: Directory

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

# << mOTUs2 >>
  motus_taxonomy:
    run: subworkflows/raw_reads/mOTUs-workflow.cwl
    in:
      reads: unzip_reads/unzipped_merged_reads
    out: [ motus ]

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

# << other ncrnas >>
  other_ncrnas:
    run: subworkflows/other_ncrnas.cwl
    in:
     input_sequences: validate_fasta/fasta_out
     cmsearch_file: classify/ncRNA
     other_ncRNA_ribosomal_models: other_ncRNA_models
     name_string: other_ncRNA_name
    out: [ ncrnas ]

# << COMBINED GENE CALLER >>
  cgc:
    in:
      input_fasta: validate_fasta/fasta_out
      seq_type: { default: 's' }
      maskfile: classify/ncRNA
      config: CGC_config
      outdir: { default: 'CGC-output' }
      postfixes: CGC_postfixes
      chunk_size: cgc_chunk_size
    out: [ results ]
    run: ../tools/Combined_gene_caller/CGC-subwf.cwl

# << FUNCTIONAL ANNOTATION: hmmscan, IPS, eggNOG >>
  functional_annotation:
    run: subworkflows/raw_reads/functional_annotation_raw.cwl
    in:
      CGC_predicted_proteins:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
      chunk_size: fa_chunk_size
      name_ips: func_ann_names_ips
      name_hmmscan: func_ann_names_hmmscan
      HMMSCAN_gathering_bit_score: HMMSCAN_gathering_bit_score
      HMMSCAN_omit_alignment: HMMSCAN_omit_alignment
      HMMSCAN_name_database: HMMSCAN_name_database
      HMMSCAN_data: HMMSCAN_data
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
    out: [ hmmscan_result, ips_result ]

# << GO SUMMARY>>
  go_summary:
    run: ../tools/GO-slim/go_summary.cwl
    in:
      InterProScan_results: functional_annotation/ips_result
      config: go_config
      output_name:
        source: validate_fasta/fasta_out
        valueFrom: $(self.nameroot).summary.go
    out: [go_summary, go_summary_slim]

# << PFAM >>
  pfam:
    run: ../tools/Pfam-Parse/pfam_annotations.cwl
    in:
      interpro: functional_annotation/ips_result
      outputname:
        source: validate_fasta/fasta_out
        valueFrom: $(self.nameroot).pfam
    out: [annotations]

# << summaries and stats IPS, HMMScan, Pfam >>
  write_summaries:
    run: subworkflows/func_summaries.cwl
    in:
       interproscan_annotation: functional_annotation/ips_result
       hmmscan_annotation: functional_annotation/hmmscan_result
       pfam_annotation: pfam/annotations
       rna: classify/ncRNA
       cds:
         source: cgc/results
         valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
    out: [summary_ips, summary_ko, summary_pfam, stats]

# << FINAL STEPS >>

# add header
  header_addition:
    scatter: [input_table, header]
    scatterMethod: dotproduct
    run: ../utils/add_header/add_header.cwl
    in:
      input_table:
        - functional_annotation/hmmscan_result
        - functional_annotation/ips_result
      header:
        - hmmscan_header
        - ips_header
    out: [ output_table ]

# gzip
  compression:
    run: ../utils/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        source:
          - validate_fasta/fasta_out                 # _FASTA
          - classify/ncRNA                        # cmsearch.all.deoverlapped
          - classify/cmsearch_result              # cmsearch.all
          - cgc/results                                 # faa, ffn
        linkMerge: merge_flattened
    out: [compressed_file]

# gzip functional annotation files
  compression_func_ann:
    run: ../utils/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        source:
          - header_addition/output_table                # hmmscan, IPS
    out: [compressed_file]

# move FUNCTIONAL-ANNOTATION
  move_to_functional_annotation_folder:
    run: ../utils/return_directory.cwl
    in:
      list:
        source:
          - compression_func_ann/compressed_file
          - write_summaries/summary_ips
          - write_summaries/summary_ko
          - write_summaries/summary_pfam
          - go_summary/go_summary
          - go_summary/go_summary_slim
        linkMerge: merge_flattened
      dir_name: { default: functional-annotation }
    out: [ out ]
