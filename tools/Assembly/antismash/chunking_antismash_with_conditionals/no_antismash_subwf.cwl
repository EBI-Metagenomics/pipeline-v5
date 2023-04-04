class: Workflow
cwlVersion: v1.2

label: "If filtered file is empty -> return file-flag no_antismash"

requirements:
  - class: ResourceRequirement
    ramMin: 5000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement

inputs:

    filtered_fasta: File
    final_folder_name: string

outputs:
  antismash_result_folder:
    type: Directory
    outputSource: return_antismash_in_folder/out

steps:

  touch_no_antismash_flag:
    run: ../../../../utils/touch_file.cwl
    in:
      filename: { default: no_antismash }
    out: [ created_file ]

  # return directory pathways-systems with "no_antismash" file inside
  return_antismash_in_folder:
    run: ../../../../utils/return_directory.cwl
    in:
      file_list:
        source:
          - touch_no_antismash_flag/created_file
        linkMerge: merge_nested
      dir_name: final_folder_name
    out: [ out ]