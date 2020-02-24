#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  ResourceRequirement:
      ramMin: 5000
      coresMin: 8
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}

inputs:

  input_fasta: File
  maskfile: File
  postfixes: string[]
  chunk_size: int

outputs:
  results:
    type: File[]
    outputSource: combine/result

steps:

  # << Chunk faa file >>
  split_seqs:
    in:
      seqs: input_fasta
      chunk_size: chunk_size
    out: [ chunks ]
    run: ../../../tools/chunks/fasta_chunker.cwl


  # << CGC >>
  combined_gene_caller:
    scatter: input_fasta
    in:
      input_fasta: split_seqs/chunks
      maskfile: maskfile
    out: [ predicted_proteins, predicted_seq ]
    run: ../../../tools/Combined_gene_caller/predict_proteins_reads.cwl
    label: CGC run


  combine:
    scatter: [ files, postfix ]
    scatterMethod: dotproduct
    in:
      files:
        - combined_gene_caller/predicted_proteins
        - combined_gene_caller/predicted_seq
      outputFileName:
        source: input_fasta
        valueFrom: $(self.nameroot)
      postfix: postfixes
    out: [result]
    run: ../../../utils/concatenate.cwl

