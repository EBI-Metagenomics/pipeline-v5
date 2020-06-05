class: Workflow
cwlVersion: v1.0

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
$schemas:
  - 'http://edamontology.org/EDAM_1.20.owl'
  - 'https://schema.org/version/latest/schema.rdf'

requirements:
  - class: ResourceRequirement
    ramMin: 10000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
    fasta: File
    ffn: File
    faa: File
    LSU: File
    SSU: File

outputs:
  nucleotide_fasta_chunks:
    type: File[]?
    outputSource: chinking_fasta_nucleotide/chunks

  protein_fasta_chunks:
    type: File[]?
    outputSource: chinking_fasta_proteins/chunks

  SC_fasta_chunks:
    type: File[]?
    outputSource: chinking_SC_fasta_nucleotide/chunks

steps:
  chinking_fasta_nucleotide:
    run: ../../utils/result-file-chunker/result_chunker.cwl
    in:
      infile:
        - fasta
        - ffn
      format_file: {default: fasta}
      outdirname: {default: folder}
      type_fasta: {default: n}
    out:
      - chunks

  chinking_fasta_proteins:
    run: ../../utils/result-file-chunker/result_chunker.cwl
    in:
      infile:
        source:
          - faa
        linkMerge: merge_nested
      format_file: {default: fasta}
      outdirname: {default: folder}
      type_fasta: {default: p}
    out:
      - chunks

  chinking_SC_fasta_nucleotide:
    run: ../../utils/result-file-chunker/result_chunker.cwl
    in:
      infile:
        - LSU
        - SSU
      format_file: {default: fasta}
      outdirname: {default: folder}
      type_fasta: {default: n}
    out:
      - chunks