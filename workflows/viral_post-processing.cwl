class: Workflow
cwlVersion: v1.0

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  input_fasta_file:  # input assembly
    type: File

outputs:

  output_prodigal:
    outputSource: subworkflow_for_each_fasta/prodigal_out
    type:
      type: array
      items: File
  output_final_mapping:
    outputSource: subworkflow_for_each_fasta/mapping_results
    type:
      type: array
      items: Directory
  output_final_assign:
    outputSource: subworkflow_for_each_fasta/assign_results
    type:
      type: array
      items: File

steps:

  hmmscan:
    in:
      seqfile: prodigal/output_fasta
    out:
      - output_table
    run: ../Tools/HMMScan/hmmscan.cwl