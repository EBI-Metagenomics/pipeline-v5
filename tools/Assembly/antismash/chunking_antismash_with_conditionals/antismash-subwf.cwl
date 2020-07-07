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
    input_names_table: File

outputs:
  antismash_js:
    type: File
    outputSource: run_antismash/geneclusters_js
  antismash_txt:
    type: File
    outputSource: run_antismash/geneclusters_txt
  antismash_gbk:
    type: File
    outputSource: fix_embl_and_gbk/fixed_gbk
  antismash_embl:
    type: File
    outputSource: fix_embl_and_gbk/fixed_embl

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

  # change DE and locus_tags
  fix_embl_and_gbk:
    run: post_rename/change_output.cwl
    in:
      embl_file: run_antismash/embl_file
      gbk_filename:
        source: fasta_file
        valueFrom: $(self.basename).gbk
      embl_filename:
        source: fasta_file
        valueFrom: $(self.basename).embl
      names_table: input_names_table
    out: [ fixed_embl, fixed_gbk ]

  # change json
