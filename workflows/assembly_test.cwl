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
    EggNOG_db: File
    EggNOG_diamond_db: File
    EggNOG_data_dir: string
    InterProScan_databases: Directory
    InterProScan_applications: string[]  # ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
    InterProScan_outputFormat: string[]  # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?
    ips_header: string

    # diamond
    Uniref90_db_txt: File
    diamond_maxTargetSeqs: int
    diamond_databaseFile: File
    diamond_header: string

    # GO
    go_config: File

    # Pathways
    graphs: File
    pathways_names: File
    pathways_classes: File

    # genome properties
    gp_flatfiles_path: string

outputs:

  qc-statistics_folder:
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

  functional_annotation_folder:
    type: Directory
    outputSource: move_to_functional_annotation_folder/out
  stats:
    outputSource: write_summaries/stats
    type: Directory

  pathways_systems_folder:
    type: Directory
    outputSource: move_to_pathways_systems_folder/out

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
      chunk_size: cgc_chunk_size
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

# << FUNCTIONAL ANNOTATION: hmmscan, IPS, eggNOG >>
  functional_annotation:
    run: subworkflows/functional_annotation.cwl
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
      EggNOG_db: EggNOG_db
      EggNOG_diamond_db: EggNOG_diamond_db
      EggNOG_data_dir: EggNOG_data_dir
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
    out: [ hmmscan_result, ips_result, eggnog_annotations, eggnog_orthologs ]

# << GO SUMMARY>>
  go_summary:
    run: ../tools/GO-slim/go_summary.cwl
    in:
      InterProScan_results: functional_annotation/ips_result
      config: go_config
      output_name:
        source: length_filter/filtered_file
        valueFrom: $(self.nameroot).summary.go
    out: [go_summary, go_summary_slim]

# << KEGG PATHWAYS >>
  pathways:
    run: subworkflows/assembly/kegg_analysis.cwl
    in:
      input_table_hmmscan: functional_annotation/hmmscan_result
      outputname:
        source: length_filter/filtered_file
        valueFrom: $(self.nameroot)
      graphs: graphs
      pathways_names: pathways_names
      pathways_classes: pathways_classes
    out: [ kegg_pathways_summary, kegg_contigs_summary]

# << PFAM >>
  pfam:
    run: ../tools/Pfam-Parse/pfam_annotations.cwl
    in:
      interpro: functional_annotation/ips_result
      outputname:
        source: length_filter/filtered_file
        valueFrom: $(self.nameroot).pfam
    out: [annotations]

# << summaries and stats IPS, HMMScan, Pfam >>
  write_summaries:
    run: subworkflows/func_summaries.cwl
    in:
       interproscan_annotation: functional_annotation/ips_result
       hmmscan_annotation: functional_annotation/hmmscan_result
       pfam_annotation: pfam/annotations
       rna: rna_prediction/ncRNA
       cds:
         source: cgc/results
         valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
    out: [summaries, stats]

# << GENOME PROPERTIES >>
  genome_properties:
    run: ../tools/Genome_properties/genome_properties.cwl
    in:
      input_tsv_file: functional_annotation/ips_result
      flatfiles_path: gp_flatfiles_path
      GP_txt: {default: genomeProperties.txt}
      name:
        source: length_filter/filtered_file
        valueFrom: $(self.nameroot).summary.gprops.tsv
    out: [ summary ]

# << GFF (IPS, EggNOG) >>
  gff:
    run: ../tools/Assembly/GFF/gff_generation.cwl
    in:
      ips_results: functional_annotation/ips_result
      eggnog_results: functional_annotation/eggnog_annotations
      input_faa:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
      output_name:
        source: length_filter/filtered_file
        valueFrom: $(self.nameroot).contigs.annotations.gff
    out: [ output_gff_gz, output_gff_index ]

# << ANTISMASH >>
#  antismash:
#    run: ../tools/Assembly/antismash/antismash_v4.cwl
#    in:
#      outdirname: {default: 'antismash_result'}
#      input_fasta: fasta
#    out: [final_gbk, final_embl, geneclusters_json, geneclusters_txt]

# << FINAL STEPS >>

# add header
  header_addition:
    scatter: [input_table, header]
    scatterMethod: dotproduct
    run: ../utils/add_header/add_header.cwl
    in:
      input_table:
        - diamond/post-processing_output
        - functional_annotation/hmmscan_result
        - functional_annotation/ips_result
      header:
        - diamond_header
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
          - length_filter/filtered_file                 # _FASTA
          - rna_prediction/ncRNA                        # cmsearch.all.deoverlapped
          - rna_prediction/cmsearch_result              # cmsearch.all
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
          - functional_annotation/eggnog_annotations
          - functional_annotation/eggnog_orthologs
          - header_addition/output_table                # hmmscan, diamond, IPS
        linkMerge: merge_flattened
    out: [compressed_file]

# move FUNCTIONAL-ANNOTATION
  move_to_functional_annotation_folder:
    run: ../utils/return_directory.cwl
    in:
      list:
        source:
          - gff/output_gff_gz
          - gff/output_gff_index
          - compression_func_ann/compressed_file
          - write_summaries/summaries
          - go_summary/go_summary
          - go_summary/go_summary_slim
        linkMerge: merge_flattened
      dir_name: { default: functional-annotation }
    out: [ out ]

# move PATHWAYS-SYSTEMS
  move_to_pathways_systems_folder:
    run: ../utils/return_directory.cwl
    in:
      list:
        source:
          - pathways/kegg_pathways_summary
          - pathways/kegg_contigs_summary
          - genome_properties/summary
        linkMerge: merge_flattened
      dir_name: { default: pathways-systems }
    out: [ out ]