class: Workflow
cwlVersion: v1.0

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  assembly:  # input assembly
    type: File
  virsorter_out:
    type: Directory
  virfinder_out:
    type: File
  predicted_proteins:
    type: File

outputs:
  output_parsing:
    outputSource: parse_pred_contigs/output_array
    type:
      type: array
      items: Directory
  output_evalue:
    outputSource: subworkflow_for_each_confidence_group/output_evalue
    type:
      type: array
      items: File

steps:

  parse_pred_contigs:
    in:
      assembly: assembly
      virfinder_tsv: virfinder_out
      virsorter_dir: virsorter_out
    out:
      - output_array
      - stdout
      - stderr
    run: ../tools/Viral/ParsingPredictions/parse_viral_pred.cwl

  subworkflow_for_each_confidence_group:
    in:
      folder_with_names: parse_pred_contigs/output_array  # array
      predicted_proteins: predicted_proteins
    out:
      - output_filtration
      - output_hmmscan
      - output_hmm_postprocessing
      - output_evalue
    scatter: folder_with_names
    run: viral_processing_subworkflow.cwl
