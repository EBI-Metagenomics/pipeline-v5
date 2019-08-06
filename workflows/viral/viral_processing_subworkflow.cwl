class: Workflow
cwlVersion: v1.0

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  folder_with_names:
    type: Directory
  predicted_proteins:
    type: File

outputs:
  output_filtration:
    outputSource: get_prodigal_predictions/chosen_faa
    type: File
  output_hmmscan:
    outputSource: hmmscan/output_table
    type: File
  output_hmm_postprocessing:
    outputSource: hmm_postprocessing/modified_file
    type: File
  output_evalue:
    outputSource: ratio_evalue/informative_table
    type: File

steps:

  get_prodigal_predictions:
    in:
      wanted_folder: folder_with_names
      predicted_file: predicted_proteins
    out:
      - chosen_faa
    run: ../tools/Viral/GetPredictedFaa/get_predicted_faa.cwl

  hmmscan:
    in:
      seqfile: get_prodigal_predictions/chosen_faa
    out:
      - output_table
    run: ../tools/Viral/HMMScan/hmmscan.cwl

  hmm_postprocessing:
    in:
      input_table: hmmscan/output_table
    out:
      - modified_file
    run: ../tools/Viral/Modification/processing_hmm_result.cwl

  ratio_evalue:
    in:
      input_table: hmm_postprocessing/modified_file
    out:
      - informative_table
    run: ../tools/Viral/RatioEvalue/ratio_evalue.cwl