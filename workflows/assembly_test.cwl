class: Workflow
cwlVersion: v1.0

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
$schemas:
  - 'http://edamontology.org/EDAM_1.20.owl'
  - 'https://schema.org/docs/schema_org_rdfa.html'

requirements:
#  - class: SchemaDefRequirement
#    types:
#      - $import: ../tools/Diamond/Diamond-strand_values.yaml
#      - $import: ../tools/Diamond/Diamond-output_formats.yaml
#      - $import: ../tools/InterProScan/InterProScan-apps.yaml
#      - $import: ../tools/InterProScan/InterProScan-protein_formats.yaml
  - class: ResourceRequirement
    ramMin: 50000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:

    contigs: File
    contig_min_length: int

    #rna prediction#
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

    # cgc
    CGC_config: File
    CGC_postfixes: string[]

    # diamond
    Uniref90_db_txt: File
    diamond_maxTargetSeqs: int
    diamond_databaseFile: File

outputs:

  qc-statistics:
    type: Directory
    outputSource: qc_stats/output_dir
  qc_summary:
    type: File
    outputSource: length_filter/stats_summary_file

  LSU_folder:
    type: Directory
    outputSource: rna_prediction/LSU_folder
  SSU_folder:
    type: Directory
    outputSource: rna_prediction/SSU_folder

  sequence-categorisation_folder:
    type: Directory
    outputSource: rna_prediction/sequence-categorisation

  compressed_files:
    type: File[]
    outputSource: compression/compressed_file

steps:
# << unzip contig file >>
  unzip:
    in:
      target_reads: contigs
      assembly: {default: true}
    out: [unzipped_merged_reads]
    run: ../utils/multiple-gunzip.cwl

# << count reads pre QC >>
  count_reads:
    in:
      sequences: unzip/unzipped_merged_reads
    out: [ count ]
    run: ../utils/count_fasta.cwl

# <<clean fasta headers??>>
  clean_headers:
    in:
      sequences: unzip/unzipped_merged_reads
    out: [ sequences_with_cleaned_headers ]
    run: ../utils/clean_fasta_headers.cwl
    label: "removes spaces in some headers"

# << Length QC >>
  length_filter:
    in:
      seq_file: unzip/unzipped_merged_reads
      min_length: contig_min_length
      submitted_seq_count: count_reads/count
      stats_file_name: { default: 'qc_summary' }
      input_file_format: { default: fasta }
    out: [filtered_file, stats_summary_file]
    run: ../tools/qc-filtering/qc-filtering.cwl

# << count processed reads >>
  count_processed_reads:
    in:
      sequences: length_filter/filtered_file
    out: [ count ]
    run: ../utils/count_fasta.cwl

# << QC stats >>
  qc_stats:
    in:
      QCed_reads: length_filter/filtered_file
      sequence_count: count_processed_reads/count
    out: [ output_dir ]
    run: ../tools/qc-stats/qc-stats.cwl

# << RNA prediction >>
  rna_prediction:
    in:
      input_sequences: length_filter/filtered_file
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
      - SSU_folder
      - LSU_folder
      - sequence-categorisation
    run: subworkflows/rna_prediction-sub-wf.cwl

# << COMBINED GENE CALLER >>
  cgc:
    in:
      input_fasta: length_filter/filtered_file
      seq_type: { default: 'a' }
      maskfile: rna_prediction/ncRNA
      config: CGC_config
      outdir: { default: 'CGC-output' }
      postfixes: CGC_postfixes
    out: [ results ]
    run: ../tools/Combined_gene_caller/CGC-subwf.cwl

# << DIAMOND >>
  diamond:
    run: ../tools/Assembly/Diamond/diamond-subwf.cwl
    in:
      queryInputFile:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
      outputFormat: { default: '6' }
      maxTargetSeqs: diamond_maxTargetSeqs
      strand: { default: 'both'}
      databaseFile: diamond_databaseFile
      threads: { default: 32 }
      Uniref90_db_txt: Uniref90_db_txt
      filename: length_filter/filtered_file
    out: [post-processing_output]

### final steps

# add header

# gzip
  compression:
    run: ../utils/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        source: [ rna_prediction/cmsearch_result, rna_prediction/ncRNA, length_filter/filtered_file, cgc/results]
        linkMerge: merge_flattened
    out: [compressed_file]