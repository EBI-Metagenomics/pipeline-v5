#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  ResourceRequirement:
      ramMin: 5000
      coresMin: 8
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  StepInputExpressionRequirement: {}

inputs:

  input_fasta: File
  maskfile: File?

outputs:
  predicted_proteins:
    type: File
    outputSource: post-processing/predicted_proteins
  predicted_seq:
    type: File
    outputSource: post-processing/predicted_seq

steps:
  prodigal:
    in:
      input_fasta: input_fasta
    out: [ predicted_proteins_out, predicted_proteins_ffn, predicted_proteins_faa ]
    run: prodigal.cwl

  FGS:
    in:
      input_fasta: input_fasta
      seq_type: { default: "1"}
      output:
        source: input_fasta
        valueFrom: $(self.basename).fgs
    out: [ predicted_proteins_out, predicted_proteins_ffn, predicted_proteins_faa ]
    run: FGS.cwl

  post-processing:
    in:
      masking_file: maskfile
      predicted_proteins_prodigal_out: prodigal/predicted_proteins_out
      predicted_proteins_prodigal_ffn: prodigal/predicted_proteins_ffn
      predicted_proteins_prodigal_faa: prodigal/predicted_proteins_faa
      predicted_proteins_fgs_out: FGS/predicted_proteins_out
      predicted_proteins_fgs_ffn: FGS/predicted_proteins_ffn
      predicted_proteins_fgs_faa: FGS/predicted_proteins_faa
      basename:
        source: input_fasta
        valueFrom: $(self.basename)
    out: [ predicted_proteins, predicted_seq ]
    run: post-processing.cwl



