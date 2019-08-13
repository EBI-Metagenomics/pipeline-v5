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
  hmmscan_gathering_bit_score:
    type: boolean
  hmmscan_omit_alignment:
    type: boolean
  hmmscan_name_database:
    type: string
  hmmscan_folder_db:
    type: Directory
  hmmscan_filter_e_value:
    type: float


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
  output_annotation:
    outputSource: annotation/annotation_table
    type: File
  output_mapping:
    outputSource: mapping/folder
    type: Directory
  output_assign:
    outputSource: assign/assign_table
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
      gathering_bit_score: hmmscan_gathering_bit_score
      name_database: hmmscan_name_database
      data: hmmscan_folder_db
      omit_alignment: hmmscan_omit_alignment
      filter_e_value: hmmscan_filter_e_value
    out:
      - output_table
    run: ../tools/hmmscan/hmmscan.cwl

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

  annotation:
    in:
      input_faa: get_prodigal_predictions/chosen_faa
      input_table: ratio_evalue/informative_table
    out:
      - annotation_table
    run: ../tools/Viral/Annotation/viral_annotation.cwl

  mapping:
    in:
      input_table: annotation/annotation_table
    out:
      - folder
      - stdout
      - stderr
    run: ../tools/Viral/Mapping/mapping.cwl

  assign:
    in:
      input_table: annotation/annotation_table
    out:
      - assign_table
    run: ../tools/Viral/Assign/assign.cwl