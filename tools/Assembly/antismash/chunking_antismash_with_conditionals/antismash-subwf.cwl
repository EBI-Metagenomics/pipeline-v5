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
    names_table: File

outputs:
  antismash_js:
    class: File
    outputSource: run_antismash/geneclusters_js
  antismash_txt:
    class: File
    outputSource: run_antismash/geneclusters_txt
  antismash_gbk:
    class: File
    outputSource: run_antismash/gbk_file
  antismash_embl:
    class: File
    outputSource: run_antismash/embl_file

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
