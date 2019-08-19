class: Workflow
cwlVersion: v1.0

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
$schemas:
  - 'http://edamontology.org/EDAM_1.20.owl'
  - 'https://schema.org/docs/schema_org_rdfa.html'

requirements:
  - class: SchemaDefRequirement
    types:
      - $import: ../tools/Diamond/Diamond-strand_values.yaml
      - $import: ../tools/Diamond/Diamond-output_formats.yaml
      - $import: ../tools/InterProScan/InterProScan-apps.yaml
      - $import: ../tools/InterProScan/InterProScan-protein_formats.yaml
  - class: ResourceRequirement
    ramMin: 1000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  contigs:
    type: File
    format: edam:format_1929  # FASTA

  Diamond_databaseFile: File
  Diamond_outFormat: ../tools/Diamond/Diamond-output_formats.yaml#output_formats?
  Diamond_maxTargetSeqs: int
  Diamond_postProcessingDB: File

  InterProScan_applications: ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
  InterProScan_outputFormat: ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?
  InterProScan_databases: Directory

  go_summary_config: File

  HMMSCAN_gathering_bit_score: boolean
  HMMSCAN_omit_alignment: boolean
  HMMSCAN_name_database: string
  HMMSCAN_data: Directory

  viral_hmmscan_gathering_bit_score: boolean
  viral_hmmscan_omit_alignment: boolean
  viral_hmmscan_name_database: string
  viral_hmmscan_folder_db: Directory
  viral_hmmscan_filter_e_value: float


outputs:

  # << QC stats >>
  qc_stats_summary:
    type: File
    outputSource: sequence_stats/summary_out
  qc_stats_seq_len_pcbin:
    type: File
    outputSource: sequence_stats/seq_length_pcbin
  qc_stats_seq_len_bin:
    type: File
    outputSource: sequence_stats/seq_length_bin
  qc_stats_seq_len:
    type: File
    outputSource: sequence_stats/seq_length_out
  qc_stats_nuc_dist:
    type: File
    outputSource: sequence_stats/nucleotide_distribution_out
  qc_stats_gc_pcbin:
    type: File
    outputSource: sequence_stats/gc_sum_pcbin
  qc_stats_gc_bin:
    type: File
    outputSource: sequence_stats/gc_sum_bin
  qc_stats_gc:
    type: File
    outputSource: sequence_stats/gc_sum_out

  # << Combined Gene Caller  >>
  CGC_predicted_proteins:
    outputSource: combined_gene_caller/predicted_proteins
    type: File
  CGC_predicted_seq:
    outputSource: combined_gene_caller/predicted_seq
    type: File

  # << Diamond >>
  Diamond_out:
    outputSource: diamond_blastp/matches
    type: File
  Diamond_annotations:
    outputSource: diamond_post_processing/join_out
    type: File

  # << InterProScan >>
  InterProScan_I5:
    outputSource: interproscan/i5Annotations
    type: File
  # Genome properties
  Genome_properties_json:
    outputSource: genome_properties/json
    type: File
  Genome_properties_table:
    outputSource: genome_properties/table
    type: File
  GO_summary:
    type: File
    outputSource: summarize_with_GO/go_summary
  GO_summary_slim:
    type: File
    outputSource: summarize_with_GO/go_summary_slim

  # << KEGG analysis >>
  #hmmscan_table:
  #  outputSource: hmmscan/output_table
  #  type: File

  # << Pathways analysis >>
  #pathways_summary:
  #  outputSource: kegg_analysis/kegg_pathways_summary
  #  type: File
  #pathways_matching:
  #  outputSource: kegg_analysis/kegg_pathways_matching
  #  type: File
  #pathways_missing:
  #  outputSource: kegg_analysis/kegg_pathways_missing
  #  type: File
  #pathways_contigs:
  #  outputSource: kegg_analysis/kegg_contigs
  #  type: Directory

  # << antiSMASH >>
  antiSMASH_results:
    outputSource: antismash/output_files
    type: Directory

  # << Viral pipeline >>
  #viral_parsing:
  #  outputSource: viral_pipeline/output_parsing
  #  type:
  #    type: array
  #    items: Directory

steps:

  # << 1. QC >>
  sequence_stats:
    in:
      QCed_reads: contigs
    out:
      - summary_out
      - seq_length_pcbin
      - seq_length_bin
      - seq_length_out
      - nucleotide_distribution_out
      - gc_sum_pcbin
      - gc_sum_bin
      - gc_sum_out
    run: ../tools/qc-stats/qc-stats.cwl

  # << 2. RNA prediction >>

  # << 3. CombinedGeneCaller >>
  combined_gene_caller:
    in:
      input_fasta: contigs
    out:
      - predicted_proteins
      - predicted_seq
      - gene_caller_out
      - stderr
      - stdout
    run: ../tools/Combined_gene_caller/combined_gene_caller.cwl
    label: "combine predictions of FragGeneScan and Prodigal with faselector"

  # << 4.1.0 InterProScan >>
  interproscan:
    in:
      applications: InterProScan_applications
      inputFile: combined_gene_caller/predicted_proteins
      outputFormat: InterProScan_outputFormat
      databases: InterProScan_databases
    out:
      - i5Annotations
    run: ../tools/InterProScan/InterProScan-v5.cwl
    label: "InterProScan: protein sequence classifier"

  # << 4.1.1 Genome Properties >>
  genome_properties:
    in:
      input_tsv_file: interproscan/i5Annotations
    out:
      - json
      - table
      - stderr
      - stdout
    run: ../tools/Genome_properties/genome_properties.cwl
    label: "Preparing summary file for genome properties"

  # << 4.1.2 GO-slim >>

  summarize_with_GO:
    doc: |
      A summary of Gene Ontology (GO) terms derived from InterPro matches to
      the sample. It is generated using a reduced list of GO terms called
      GO slim (http://www.geneontology.org/ontology/subsets/goslim_metagenomics.obo)
    run: ../tools/GO-slim/go_summary.cwl
    in:
      InterProScan_results: interproscan/i5Annotations
      config: go_summary_config
    out: [ go_summary, go_summary_slim ]

  # << 4.2.0 KEGG >>
  #hmmscan:
  #  in:
  #    seqfile: combined_gene_caller/predicted_proteins
  #    gathering_bit_score: HMMSCAN_gathering_bit_score
  #    name_database: HMMSCAN_name_database
  #    data: HMMSCAN_data
  #    omit_alignment: HMMSCAN_omit_alignment
  #  out:
  #    - output_table
  #  run: ../tools/hmmscan/hmmscan.cwl
  #  label: "Analysis using profile HMM on db"

  # << 4.2.1 Pathways >>
  #kegg_analysis:
  #  in:
  #    input_table_hmmscan: hmmscan/output_table
  #  out:
  #    - modification_out
  #    - parsing_hmmscan_out
  #    - kegg_pathways_summary
  #    - kegg_pathways_matching
  #    - kegg_pathways_missing
  #    - kegg_contigs
  #    - kegg_stdout
  #  run: kegg_analysis.cwl

  # << 4.3.0 COGs >>
  # make db
  # run EggNOG

  # << 4.4.0 Diamond >>
  diamond_blastp:
    in:
      databaseFile: Diamond_databaseFile
      outputFormat: Diamond_outFormat
      queryInputFile: combined_gene_caller/predicted_proteins
      maxTargetSeqs: Diamond_maxTargetSeqs
    out:
      - matches
    run: ../tools/Diamond/Diamond.blastp-v0.9.21.cwl
    label: "align DNA query sequences against a protein reference UniRef90 database"

  # << 4.4.1 Diamond post-processing >>
  diamond_post_processing:
    in:
      input_diamond: diamond_blastp/matches
      input_db: Diamond_postProcessingDB
    out:
      - join_out
    run: ../tools/Diamond-Post-Processing/postprocessing_pipeline.cwl
    label: "add additional annotation to diamond matches"

  # << 4.5.0 Antismash >>
  antismash:
    in:
      input_fasta: contigs # TODO change to right file
    out:
      - output_files
    run: ../tools/antismash/antismash.cwl
    label: "analysis of secondary metabolite biosynthesis gene clusters in bacterial and fungal genomes"

  # << 4.6.0 Viral >>
  #viral_pipeline:
  #  in:
  #    assembly: combined_gene_caller/predicted_seq
  #    predicted_proteins: combined_gene_caller/predicted_proteins
  #    hmmscan_gathering_bit_score: viral_hmmscan_gathering_bit_score
  #    hmmscan_omit_alignment: viral_hmmscan_omit_alignment
  #    hmmscan_name_database: viral_hmmscan_name_database
  #    hmmscan_folder_db: viral_hmmscan_folder_db
  #    hmmscan_filter_e_value: viral_hmmscan_filter_e_value
  #  out:
  #    - output_parsing
  #    - output_final_mapping
  #    - output_final_assign
  #  run: viral_pipeline.cwl
  #  label: "detecting and processing viral sequences"