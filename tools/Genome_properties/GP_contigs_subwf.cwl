class: Workflow
cwlVersion: v1.0

requirements:
  - class: ResourceRequirement
    ramMin: 40000
    coresMin: 32
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_table: File
  flatfiles_path: string
  GP_txt : string

outputs:
  summaries:
    type: File[]
    outputBinding: "SUMMARY*"

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
      flatfiles_path: flatfiles_path
      GP_txt: GP_txt
    out: [summary]

