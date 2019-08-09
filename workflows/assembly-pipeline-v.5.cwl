class: Workflow
cwlVersion: v1.0

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  contigs:
    type: File

outputs:
  CGC_predicted_proteins:
    outputSource: combined_gene_caller/predicted_proteins
    type: File

  CGC_predicted_seq:
    outputSource: combined_gene_caller/predicted_seq
    type: File
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


  # << Diamond blastp >>
  # << Diamond post-processing >>
