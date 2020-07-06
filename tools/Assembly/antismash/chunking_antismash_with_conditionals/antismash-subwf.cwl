class: Workflow
cwlVersion: v1.2.0-dev2

label: "antismash + change locus tag "

requirements:
  - class: ResourceRequirement
    ramMin: 5000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
    fasta_file: File

outputs: []

steps:

  run_antismash:
    run: antismash_v4.cwl
    in:
      input_fasta: fasta_file
      outdirname: { default: antismash_result}
    out:
      - geneclusters_js
      - geneclusters_txt
      - embl_file
      - gbk_file

  # change DE
  # change locus_tag

  # change json
