#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  ResourceRequirement:
      ramMin: 1000
      coresMin: 1
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}

inputs:

  CGC_predicted_proteins: File
  chunk_size: int

  name_hmmscan: string

  HMMSCAN_gathering_bit_score: boolean
  HMMSCAN_omit_alignment: boolean
  HMMSCAN_name_database: string
  HMMSCAN_data: Directory

  previous_step_result: File?

outputs:
  hmmscan_result:
    type: File
    outputSource: combine_hmmscan/result

steps:

  # << Chunk faa file >>
  split_seqs:
    in:
      seqs: CGC_predicted_proteins
      chunk_size: chunk_size
    out: [ chunks ]
    run: ../../tools/chunks/protein_chunker.cwl

  # << hmmscan >>
  hmmscan:
    scatter: seqfile
    in:
      seqfile: split_seqs/chunks
      gathering_bit_score: HMMSCAN_gathering_bit_score
      name_database: HMMSCAN_name_database
      data: HMMSCAN_data
      omit_alignment: HMMSCAN_omit_alignment
    out: [ output_table ]
    run: ../../tools/hmmscan/hmmscan-subwf.cwl
    label: "Analysis using profile HMM on db"

  combine_hmmscan:
    in:
      files: hmmscan/output_table
      outputFileName:
        source: CGC_predicted_proteins
        valueFrom: $(self.nameroot.split('_CDS')[0])
      postfix: name_hmmscan
    out: [result]
    run: ../../utils/concatenate.cwl
