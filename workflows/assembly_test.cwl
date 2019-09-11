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
#  Diamond_outFormat: ../tools/Diamond/Diamond-output_formats.yaml#output_formats?
  Diamond_maxTargetSeqs: int
  Diamond_postProcessingDB: File


outputs: []

steps:

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

