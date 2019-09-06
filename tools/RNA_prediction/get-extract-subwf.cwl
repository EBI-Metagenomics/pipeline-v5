cwlVersion: v1.0
class: Workflow

#requirements:
# DockerRequirement:
#    dockerPull: alpine:3.7

requirements:
  - class: ScatterFeatureRequirement
  - class: SubworkflowFeatureRequirement

inputs:
  input_file: File
  input_pattern: string
  index_reads: File

outputs:
  - id: finalOutFiles
    type: File
    outputSource: get_coords/grepped_file
#    outputSource: extract_sequences/sequences

steps:
  get_coords:
    run: extract_grep.cwl
    in:
      input_file: input_file
      pattern: input_pattern
    out: [ grepped_file ]

#  extract_coords:
#    run: extract-coords_awk.cwl
#    in:
#      infernal_matches: get_coords/grepped_file
#    out: [ matched_seqs_with_coords ]

#  extract_sequences:
#    run: ../easel/esl-sfetch-manyseqs.cwl
#    in:
#      indexed_sequences: index_reads
#      names_contain_subseq_coords: extract_coords/matched_seqs_with_coords
#    out: [ sequences ]
