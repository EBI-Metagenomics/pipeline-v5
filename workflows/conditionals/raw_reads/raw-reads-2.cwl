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
    motus_input: File
    filtered_fasta: File

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
  motus_output:
    type: File
    outputSource: motus_taxonomy/motus

  LSU_folder:
    type: Directory
    outputSource: classify/LSU_folder
  SSU_folder:
    type: Directory
    outputSource: classify/SSU_folder

  sequence-categorisation_folder:
    type: Directory
    outputSource: classify/sequence-categorisation
  compressed_sequence_categorisation:
    type: Directory
    outputSource: move_to_seq_cat_folder/out
  ncrnas_folder:
    type: Directory
    outputSource: other_ncrnas/ncrnas

  chunking_nucleotides:
    type: File[]
    outputSource: chunking_final/nucleotide_fasta_chunks
  chunking_proteins:
    type: File[]
    outputSource: chunking_final/protein_fasta_chunks
  rna-count:
    type: File
    outputSource: classify/LSU-SSU-count

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
# << mOTUs2 >>
  motus_taxonomy:
    run: ../../subworkflows/raw_reads/mOTUs-workflow.cwl
    in:
      reads: motus_input
    out: [ motus ]

# << Get RNA >>
  classify:
    run: ../../subworkflows/rna_prediction-sub-wf.cwl
    in:
      input_sequences: filtered_fasta
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
      - LSU_fasta_file
      - SSU_fasta_file

# << other ncrnas >>
  other_ncrnas:
    run: ../../subworkflows/other_ncrnas.cwl
    in:
     input_sequences: filtered_fasta
     cmsearch_file: classify/ncRNA
     other_ncRNA_ribosomal_models: other_ncRNA_models
     name_string: { default: 'other_ncrna' }
    out: [ ncrnas ]

# << COMBINED GENE CALLER >>
  cgc:
    in:
      input_fasta: filtered_fasta
      seq_type: { default: 's' }
      maskfile: classify/ncRNA
      config: CGC_config
      outdir: { default: 'CGC-output' }
      postfixes: CGC_postfixes
      chunk_size: cgc_chunk_size
    out: [ results ]
    run: ../../../tools/Combined_gene_caller/CGC-subwf.cwl

# << FUNCTIONAL ANNOTATION: hmmscan, IPS, eggNOG >>
  functional_annotation:
    run: ../../subworkflows/raw_reads/functional_annotation_raw.cwl
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
    run: ../../../tools/GO-slim/go_summary.cwl
    in:
      InterProScan_results: functional_annotation/ips_result
      config: go_config
      output_name:
        source: filtered_fasta
        valueFrom: $(self.nameroot).summary.go
    out: [go_summary, go_summary_slim]

# << PFAM >>
  pfam:
    run: ../../../tools/Pfam-Parse/pfam_annotations.cwl
    in:
      interpro: functional_annotation/ips_result
      outputname:
        source: filtered_fasta
        valueFrom: $(self.nameroot).pfam
    out: [annotations]

# << summaries and stats IPS, HMMScan, Pfam >>
  write_summaries:
    run: ../../subworkflows/func_summaries.cwl
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

# << TAXONOMY FORMATTING AND CHUNKING >>

# gzip
  compression:
    run: ../../../utils/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        source:
          - filtered_fasta                        # _FASTA
          - classify/ncRNA                        # cmsearch.all.deoverlapped
          - classify/cmsearch_result              # cmsearch.all
        linkMerge: merge_flattened
    out: [compressed_file]

# << chunking >>
  chunking_final:
    run: ../../subworkflows/final_chunking.cwl
    in:
      fasta: filtered_fasta
      ffn:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.ffn.*$/)).pop() )
      faa:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
      LSU: classify/LSU_fasta_file
      SSU: classify/SSU_fasta_file
    out:
      - nucleotide_fasta_chunks                         # fasta, ffn
      - protein_fasta_chunks                            # faa
      - SC_fasta_chunks                                 # LSU, SSU

# << move to sequence categorisation >>
  move_to_seq_cat_folder:  # LSU and SSU
    run: ../../../utils/return_directory.cwl
    in:
      list: chunking_final/SC_fasta_chunks
      dir_name: { default: sequence-categorisation }
    out: [ out ]


# << FUNCTIONAL FORMATTING AND CHUNKING >>

# add header
  header_addition:
    scatter: [input_table, header]
    scatterMethod: dotproduct
    run: ../../../utils/add_header/add_header.cwl
    in:
      input_table:
        - functional_annotation/hmmscan_result
        - functional_annotation/ips_result
      header:
        - hmmscan_header
        - ips_header
    out: [ output_table ]

# << chunking TSVs >>
  chunking_tsv:
    run: ../../../utils/result-file-chunker/result_chunker.cwl
    in:
      infile: header_addition/output_table
      format_file: { default: tsv }
      outdirname: { default: table }
    out: [chunks]

# << move to fucntional annotation >>
  move_to_functional_annotation_folder:
    run: ../../../utils/return_directory.cwl
    in:
      list:
        source:
          - write_summaries/summary_ips
          - write_summaries/summary_ko
          - write_summaries/summary_pfam
          - go_summary/go_summary
          - go_summary/go_summary_slim
          - chunking_tsv/chunks
        linkMerge: merge_flattened
      dir_name: { default: functional-annotation }
    out: [ out ]

