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

outputs:

  # combined gene caller
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

  # Viral pipeline
  #viral_parsing:
  #  outputSource: viral_pipeline/output_parsing
  #  type:
  #    type: array
  #    items: Directory

steps:

  # << QC >> don't dockerized ???



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

  diamond_blastp:
    in:
      databaseFile: Diamond_databaseFile
      outputFormat: Diamond_outFormat
      queryInputFile: combined_gene_caller/predicted_proteins  # Diamond_test
    out:
      - matches
    run: ../tools/Diamond/Diamond.blastp-v0.9.21.cwl
    label: "align DNA query sequences against a protein reference UniRef90 database"


  # << Diamond post-processing >>


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