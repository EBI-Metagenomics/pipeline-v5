class: Workflow
cwlVersion: v1.2

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
    accession: string

outputs:
  antismash_txt:
    type: File
    outputSource: fix_geneclusters_txt/fixed_txt
  antismash_gbk:
    type: File
    outputSource: fix_embl_and_gbk/fixed_gbk
  antismash_embl:
    type: File
    outputSource: fix_embl_and_gbk/fixed_embl

steps:

  run_antismash:
    run: antismash/antismash_v4.cwl
    in:
      input_fasta: fasta_file
      outdirname: { default: antismash_result}
      accession: accession
      chunk_num:
        source: fasta_file
        valueFrom: $(self.nameext)
    out:
      - geneclusters_txt
      - embl_file
      - gbk_file

  # change DE and locus_tags
  fix_embl_and_gbk:
    run: post-processing/fix_embl_gbk/change_output.cwl
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

  # change txt
  fix_geneclusters_txt:
    run: post-processing/fix_geneclusters_txt/change_geneclusters_txt.cwl
    in:
      input_geneclusters_txt: run_antismash/geneclusters_txt
      output_filename:
        source: fasta_file
        valueFrom: $(self.basename).gncl.txt
    out: [ fixed_txt ]
