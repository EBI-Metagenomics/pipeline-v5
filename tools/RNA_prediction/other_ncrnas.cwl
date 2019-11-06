#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

label: "extract other ncrnas!"

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  input_sequences: {type: File, secondaryFiles: [.ssi] }
  cmsearch_file: File
  other_ncRNA_ribosomal_models: string[]
  name_string: string

outputs:
  ncrnas:
    type: Directory
    outputSource: move_fastas/out

steps:

  extract_coords:
    run: extract-coords_awk.cwl
    in:
      infernal_matches: cmsearch_file
      name: name_string
    out: [ matched_seqs_with_coords ]

  get_coords:
    run: pull_ncrnas.cwl
    in:
      hits: extract_coords/matched_seqs_with_coords
      model: other_ncRNA_ribosomal_models
    out: [ matches ]

  get_ncrnas:
    run: ../easel/esl-sfetch-manyseqs.cwl
    scatter: names_contain_subseq_coords
    in:
      names_contain_subseq_coords: get_coords/matches
      indexed_sequences: input_sequences
    out: [ sequences ]

  rename_ncrnas:
    run: ../../utils/move.cwl
    scatter: initial_file
    in:
      initial_file: get_ncrnas/sequences
      out_file_name:
        valueFrom: $(inputs.initial_file.nameroot.split("fasta_")[1]).fasta
    out: [ renamed_file ]

  gzip_files:
    run: ../../utils/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file: rename_ncrnas/renamed_file
    out: [compressed_file]

  move_fastas:
    run: ../../utils/return_directory.cwl
    in:
      list: gzip_files/compressed_file
      dir_name: { default: 'sequence-categorisation' }
    out: [out]














