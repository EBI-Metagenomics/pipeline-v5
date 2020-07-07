class: Workflow
cwlVersion: v1.2.0-dev2

label: "WF leaves sequences that length is more than 5000bp, run antismash + gene clusters post-processing, GFF generation"

requirements:
  - class: ResourceRequirement
    ramMin: 5000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
    filtered_fasta: File
    clusters_glossary: File
    final_folder_name: string
    split_size: int

outputs:
  renamed:
    type: File[]
    outputSource: rename_contigs/renamed_contigs_in_chunks
  help_dict:
    type: File[]
    outputSource: rename_contigs/names_table
  antismash_js:
    type: File[]
    outputSource: run_antismash/antismash_js
  antismash_txt:
    type: File[]
    outputSource: run_antismash/antismash_txt
  antismash_gbk:
    type: File[]
    outputSource: run_antismash/antismash_gbk
  antismash_embl:
    type: File[]
    outputSource: run_antismash/antismash_embl

steps:
  calc_chunking_number:
    run: ../../../../utils/count_fasta.cwl
    in:
      sequences: filtered_fasta
      number: split_size
    out: [ count ]

  chunking_fasta:
    run: ../../../chunks/dna_chunker/fasta_chunker.cwl
    in:
      seqs: filtered_fasta
      chunk_size: calc_chunking_number/count
      number_of_output_files: { default: True }
      same_number_of_residues: { default: True }
    out: [ chunks ]

  rename_contigs:
    run: rename_contigs/rename_contigs.cwl
    scatter: chunks
    in:
      full_fasta: filtered_fasta
      chunks: chunking_fasta/chunks
      accession:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
    out: [ renamed_contigs_in_chunks, names_table ]

  run_antismash:
    run: antismash-subwf.cwl
    scatter: [fasta_file, names_table]
    scatterMethod: dotproduct
    in:
      fasta_file: rename_contigs/renamed_contigs_in_chunks
      input_names_table: rename_contigs/names_table
      accession:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
    out:
      - antismash_js
      - antismash_txt
      - antismash_gbk
      - antismash_embl
