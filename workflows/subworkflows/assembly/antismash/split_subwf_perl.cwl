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
    infile: File
    size_limit: int

outputs:

  chunks:
    type: File[]
    outputSource: chunking_fasta/chunks

steps:

  calc_chunking_number:
    run: ../../../../utils/count_fasta.cwl
    in:
      sequences: infile
      number: size_limit
    out: [ count ]

  check_value:
    run: ../../../../tools/Assembly/antismash/chunking_antismash_with_conditionals/check_value/check_value.cwl
    in:
      number: calc_chunking_number/count
    out: [ out ]

  chunking_fasta:
    run: ../../../../tools/chunks/dna_chunker/fasta_chunker.cwl
    in:
      seqs: infile
      chunk_size: check_value/out
      number_of_output_files: { default: "True" }
      same_number_of_residues: { default: "True" }
    out: [ chunks ]