class: Workflow
cwlVersion: v1.0

requirements:
  - class: ResourceRequirement
    ramMin: 10000
    coresMin: 32
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_table: File

outputs: []

steps:

  split_interpro:
    run: split_by_contigs.cwl
    in:
      input_table: input_table
    out: [ files_by_contigs ]

  run_gp:
    run: genome_properties.cwl
    scatter: input_tsv_file
    in:
      input_tsv_file: split_interpro/files_by_contigs
      flatfiles_path: {default: '/genome-properties/flatfiles'}
      GP_txt: {default: 'genomeProperties.txt'}
    out: [summary]

