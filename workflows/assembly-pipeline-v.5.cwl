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

  # Viral pipeline
  #viral_parsing:
  #  outputSource: viral_pipeline/output_parsing
  #  type:
  #    type: array
  #    items: Directory

steps:

  # << QC >> don't dockerized ???

  # << CombinedGeneCaller >>
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

  # << InterProScan >>
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

  # << Genome Properties >>
  genome_properties:
    in:
      input_tsv_file: interproscan/i5Annotations
    out:
      - summary
      - stderr
      - stdout
    run: ../tools/Genome_properties/genome_properties.cwl
    label: "Preparing summary file for genome properties"

  # << Diamond >>
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

  diamond_post_processing:
    in:
      input_diamond: diamond_blastp/matches
      input_db: Diamond_postProcessingDB
    out:
      - join_out
    run: ../tools/Diamond-Post-Processing/postprocessing_pipeline.cwl
    label: "add additional annotation to diamond matches"

  # << Viral >>
  #viral_pipeline:
  #  in:
  #    assembly: combined_gene_caller/predicted_seq
  #    predicted_proteins: combined_gene_caller/predicted_proteins
  #  out:
  #    - output_parsing
  #    - output_final_mapping
  #    - output_final_assign
  #  run: viral_pipeline.cwl
  #  label: "detecting and processing viral sequences"