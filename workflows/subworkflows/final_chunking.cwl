class: Workflow
cwlVersion: v1.2.0-dev4

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
$schemas:
  - 'http://edamontology.org/EDAM_1.20.owl'
  - 'https://schema.org/version/latest/schemaorg-current-http.rdf'

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
    LSU: File?
    SSU: File?

outputs:
  nucleotide_fasta_chunks:
    type: File[]?
    outputSource: chinking_fasta_nucleotide/chunked_by_size_files

  protein_fasta_chunks:
    type: File[]?
    outputSource: chinking_fasta_proteins/chunked_by_size_files

  SC_fasta_chunks:
    type: File[]?
    outputSource: chinking_SC_fasta_nucleotide/chunked_by_size_files

  nucleotide_chunks_files:
    type: File[]?
    outputSource: chinking_fasta_nucleotide/chunked_files

  protein_chunks_files:
    type: File[]?
    outputSource: chinking_fasta_proteins/chunked_files

  SC_fasta_chunks_files:
    type: File[]?
    outputSource: chinking_SC_fasta_nucleotide/chunked_files

steps:
  chinking_fasta_nucleotide:
    run: ../../utils/result-file-chunker/result_chunker_subwf.cwl
    in:
      input_files:
        - fasta
        - ffn
      format: {default: fasta}
      type_fasta: {default: n}
    out:
      - chunked_by_size_files
      - chunked_files

  chinking_fasta_proteins:
    run: ../../utils/result-file-chunker/result_chunker_subwf.cwl
    in:
      input_files:
        source:
          - faa
        linkMerge: merge_nested
      format: {default: fasta}
      type_fasta: {default: p}
    out:
      - chunked_by_size_files
      - chunked_files

  chinking_SC_fasta_nucleotide:
    when: $(inputs.lsu != null && inputs.ssu != null)
    run: ../../utils/result-file-chunker/result_chunker_subwf.cwl
    in:
      lsu: LSU
      ssu: SSU
      input_files:
        - LSU
        - SSU
      format: {default: fasta}
      type_fasta: {default: n}
    out:
      - chunked_by_size_files
      - chunked_files