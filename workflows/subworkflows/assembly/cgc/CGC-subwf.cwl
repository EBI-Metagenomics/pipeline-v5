#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  ResourceRequirement:
      ramMin: 5000
      coresMin: 8
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:

  input_fasta: File
  maskfile: File?
  postfixes: string[]
  chunk_size: int

outputs:
  predicted_proteins:
    type: File
    format: edam:format_1929
    outputSource: combine_faa/result
  predicted_seq:
    type: File
    format: edam:format_1929
    outputSource: combine_ffn/result
  count_faa:
    type: int
    outputSource: count_cds/count

steps:

  # << Chunk faa file >>
  split_seqs:
    in:
      seqs: input_fasta
      chunk_size: chunk_size
      number_of_output_files: { default: "False" }
      same_number_of_residues: { default: "False" }
    out: [ chunks ]
    run: ../../../../tools/chunks/dna_chunker/fasta_chunker.cwl


  # << CGC >>
  combined_gene_caller:
    scatter: input_fasta
    in:
      input_fasta: split_seqs/chunks
      maskfile: maskfile
    out: [ predicted_proteins, predicted_seq ]
    run: predict_proteins_assemblies.cwl
    label: CGC run

  combine_faa:
    in:
      files: combined_gene_caller/predicted_proteins
      outputFileName:
        source: input_fasta
        valueFrom: $(self.nameroot)
      postfix:
        source: postfixes
        valueFrom: $(self[0])
    out: [result]
    run: ../../../../utils/concatenate.cwl

  combine_ffn:
    in:
      files: combined_gene_caller/predicted_seq
      outputFileName:
        source: input_fasta
        valueFrom: $(self.nameroot)
      postfix:
        source: postfixes
        valueFrom: $(self[1])
    out: [result]
    run: ../../../../utils/concatenate.cwl

  count_cds:
    run: ../../../../utils/count_fasta.cwl
    in:
      sequences: combine_faa/result
      number: { default: 1 }
    out: [ count ]


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"
