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
    ramMin: 10000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement


inputs:
  contigs: File

# rna prediction
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

# diamond
#  Diamond_databaseFile: File
#  Diamond_outFormat: string  # ../tools/Diamond/Diamond-output_formats.yaml#output_formats?
#  Diamond_maxTargetSeqs: int
#  Diamond_postProcessingDB: File


outputs: []

steps:

# << QC >>

# << RNA PREDICTION >>
  identify_ncrna:
    run: rna_prediction-sub-wf.cwl
    in:
       input_sequences: contigs
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
    out:
      - ncRNAs
      - 5S_fasta
      - SSU_fasta
      - LSU_fasta
      - SSU_coords
      - LSU_coords
      - SSU_classifications
      - SSU_otu_tsv
      - SSU_otu_txt
      - SSU_krona_image
      - LSU_classifications
      - LSU_otu_tsv
      - LSU_otu_txt
      - LSU_krona_image
#      - ssu_hdf5_classifications
#      - ssu_json_classifications
#      - lsu_hdf5_classifications
#      - lsu_json_classifications

# << CHUNKS >>

# << FUNCTIONAL ANNOTATION >>

# << DIAMOND >>
#  diamond_blastp:
#    in:
#      databaseFile: Diamond_databaseFile
#      outputFormat: Diamond_outFormat
#      queryInputFile: combined_gene_caller/predicted_proteins
#      maxTargetSeqs: Diamond_maxTargetSeqs
#    out:
#      - matches
#    run: ../tools/Diamond/Diamond.blastp-v0.9.21.cwl
#    label: "align DNA query sequences against a protein reference UniRef90 database"

