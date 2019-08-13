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

  Diamond_databaseFile:
    type: File
  Diamond_outFormat:
    type: ../tools/Diamond/Diamond-output_formats.yaml#output_formats?
  Diamond_maxTargetSeqs:
    type: int
  Diamond_postProcessingDB:
    type: File

  InterProScan_applications:
    type: ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
  InterProScan_outputFormat:
    type: ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?
  InterProScan_databases:
    type: Directory

  HMMSCAN_gathering_bit_score:
    type: boolean
  HMMSCAN_omit_alignment:
    type: boolean
  HMMSCAN_name_database:
    type: string
  HMMSCAN_data:
    type: Directory

  viral_hmmscan_gathering_bit_score:
    type: boolean
  viral_hmmscan_omit_alignment:
    type: boolean
  viral_hmmscan_name_database:
    type: string
  viral_hmmscan_folder_db:
    type: Directory
  viral_hmmscan_filter_e_value:
    type: float


outputs:
  # Combined Gene Caller
  CGC_predicted_proteins:
    outputSource: combined_gene_caller/predicted_proteins
    type: File
  CGC_predicted_seq:
    outputSource: combined_gene_caller/predicted_seq
    type: File

  # Diamond
  Diamond_out:
    outputSource: diamond_blastp/matches
    type: File
  Diamond_annotations:
    outputSource: diamond_post_processing/join_out
    type: File

  # InterProScan
  InterProScan_I5:
    outputSource: interproscan/i5Annotations
    type: File
  # Genome properties
  Genome_properties_summary:
    outputSource: genome_properties/summary
    type: File

  # KEGG analysis
  hmmscan_table:
    outputSource: hmmscan/output_table
    type: File

  pathways_summary:
    outputSource: kegg_analysis/kegg_pathways_summary
    type: File
  pathways_matching:
    outputSource: kegg_analysis/kegg_pathways_matching
    type: File
  pathways_missing:
    outputSource: kegg_analysis/kegg_pathways_missing
    type: File
  pathways_contigs:
    outputSource: kegg_analysis/kegg_contigs
    type: Directory


  # Viral pipeline
  #viral_parsing:
  #  outputSource: viral_pipeline/output_parsing
  #  type:
  #    type: array
  #    items: Directory

steps:

  # << 1. QC >> don't dockerized ???

  # << 2. CombinedGeneCaller >>
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

  # << 3.1.0 InterProScan >>
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

  # << 3.1.1 Genome Properties >>
  genome_properties:
    in:
      input_tsv_file: interproscan/i5Annotations
    out:
      - summary
      - stderr
      - stdout
    run: ../tools/Genome_properties/genome_properties.cwl
    label: "Preparing summary file for genome properties"

  # << 3.2.0 KEGG >>
  hmmscan:
    in:
      seqfile: combined_gene_caller/predicted_proteins
      gathering_bit_score: HMMSCAN_gathering_bit_score
      name_database: HMMSCAN_name_database
      data: HMMSCAN_data
      omit_alignment: HMMSCAN_omit_alignment
    out:
      - output_table
    run: ../tools/hmmscan/hmmscan.cwl
    label: "Analysis using profile HMM on db"

  # << 3.2.1 Pathways >>
  kegg_analysis:
    in:
      input_table_hmmscan: hmmscan/output_table
    out:
      - modification_out
      - parsing_hmmscan_out
      - kegg_pathways_summary
      - kegg_pathways_matching
      - kegg_pathways_missing
      - kegg_contigs
      - kegg_stdout
    run: kegg_analysis.cwl

  # << 3.3.0 COGs >>

  # << 3.4.0 Diamond >>
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

  # << 3.4.1 Diamond post-processing >>
  diamond_post_processing:
    in:
      input_diamond: diamond_blastp/matches
      input_db: Diamond_postProcessingDB
    out:
      - join_out
    run: ../tools/Diamond-Post-Processing/postprocessing_pipeline.cwl
    label: "add additional annotation to diamond matches"

  # << 3.5.0 Antismash >>

  # << 3.6.0 Viral >>
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