#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  ResourceRequirement:
      ramMin: 5000
      coresMin: 8
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  StepInputExpressionRequirement: {}
  InlineJavascriptRequirement: {}

inputs:

  input_fasta: File
  maskfile: File
  postfixes: string[]
  chunk_size: int
  diamond_maxTargetSeqs: int
  diamond_databaseFile: File
  Uniref90_db_txt: File

outputs:
  results:
    type: File
    outputSource: diamond/post-processing_output

steps:

  # << Chunk faa file >>
  split_seqs:
    in:
      seqs: input_fasta
      chunk_size: chunk_size
    out: [ chunks ]
    run: chunks/fasta_chunker.cwl


  # << CGC >>
  combined_gene_caller:
    scatter: input_fasta
    in:
      input_fasta: split_seqs/chunks
      maskfile: maskfile
    out: [ predicted_proteins, predicted_seq ]
    run: Combined_gene_caller/predict_proteins_assemblies.cwl
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
    run: ../utils/concatenate.cwl

  diamond:
    run: Assembly/Diamond/diamond-subwf.cwl
    in:
      queryInputFile:
        source: combine/result
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
      outputFormat: { default: '6' }
      maxTargetSeqs: diamond_maxTargetSeqs
      strand: { default: 'both'}
      databaseFile: diamond_databaseFile
      threads: { default: 32 }
      Uniref90_db_txt: Uniref90_db_txt
      filename: input_fasta
    out: [post-processing_output]