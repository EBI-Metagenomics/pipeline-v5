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
  seq_type: string
  maskfile: File
  config: File
  outdir: string

outputs:
  results:
    type: File[]
    outputSource: combine/result

steps:

  # << Chunk faa file >>
  split_seqs:
    in:
      seqs: input_fasta
      chunk_size: { default: 2000 }  # 100000
    out: [ chunks ]
    run: ../tools/chunks/fasta_chunker.cwl


  # << CGC >>
  combined_gene_caller:
    scatter: input_fasta
    in:
      input_fasta: split_seqs/chunks
      seq_type: seq_type
      maskfile: maskfile
      config: config
      outdir: outdir
    out: [ predicted_proteins, predicted_seq ]
    run: combined_gene_caller.cwl
    label: CGC run


  combine:
    scatter: files
    in:
      files:
        - combined_gene_caller/predicted_proteins
        - combined_gene_caller/predicted_seq
      outputFileName: input_fasta
    out: [result]
    run: ../chunks/concatenate.cwl

