class: Workflow
cwlVersion: v1.2.0-dev4

label: "WF leaves sequences that length is more than 1000bp, run antismash + gene clusters post-processing, GFF generation"

requirements:
  - class: ResourceRequirement
    ramMin: 5000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
    input_filtered_fasta: File
    clusters_glossary: [string, File]
    final_folder_name: string
    chunk_size:
      type: int?
      default: 100000
    contig_min_limit:
      type: int?
      default: 5000

outputs:
  antismash_folder:
    type: Directory
    outputSource:
      - no_antismash_subwf/antismash_result_folder
      - chunking/antismash_folder_chunking
    pickValue: first_non_null

  antismash_clusters:
    type: File?
    outputSource: chunking/antismash_clusters


steps:

  filtering:
    run: filtering_fasta_for_antismash.cwl
    in:
      fasta: input_filtered_fasta
      contig_min_limit: { default: 5000 }
    out:
      - filtered_fasta_for_antismash
      - count_after_filtering

  no_antismash_subwf:
    when: $(inputs.value == 0)
    run: no_antismash_subwf.cwl
    in:
      filtered_fasta: filtering/filtered_fasta_for_antismash
      final_folder_name: final_folder_name
      value: filtering/count_after_filtering
    out: [ antismash_result_folder ]

  chunking:
    when: $(inputs.value > 0)
    run: antismash_chunking_subwf.cwl
    in:
      filtered_fasta: filtering/filtered_fasta_for_antismash
      clusters_glossary: clusters_glossary
      final_folder_name: final_folder_name
      split_size: { default: 1000 }
      value: filtering/count_after_filtering
    out: [ antismash_folder_chunking, antismash_clusters ]
