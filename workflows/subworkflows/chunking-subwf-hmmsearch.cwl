#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  ResourceRequirement:
      ramMin: 1000
      coresMin: 1
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:

  CGC_predicted_proteins: File
  chunk_size: int

  name_hmmer: string

  HMM_gathering_bit_score: boolean
  HMM_omit_alignment: boolean
  HMM_database: string
  HMM_database_dir: Directory?
  previous_step_result: File?

outputs:
  hmm_result:
    type: File
    outputSource: make_tab_sep/output_with_tabs

steps:

  # << Chunk faa file >>
  split_seqs:
    in:
      seqs: CGC_predicted_proteins
      chunk_size: chunk_size
    out: [ chunks ]
    run: ../../tools/chunks/protein_chunker.cwl

  # << hmmsearch >>
  hmmsearch:
    scatter: seqfile
    in:
      seqfile: split_seqs/chunks
      database: HMM_database
      database_dir: HMM_database_dir
      gathering_bit_score: HMM_gathering_bit_score
      omit_alignment: HMM_omit_alignment
    out: [ output_table ]
    run: ../../tools/hmmer/hmmsearch.cwl
    label: "Analysis using profile HMM on db"

  combine:
    in:
      files: hmmsearch/output_table
      outputFileName:
        source: CGC_predicted_proteins
        valueFrom: $(self.nameroot.split('_CDS')[0])
      postfix: name_hmmer
    out: [result]
    run: ../../utils/concatenate.cwl

  make_tab_sep:
    run: ../../tools/hmmer/hmmscan_tab_modification/hmmscan_tab_modification.cwl
    in:
      input_table: combine/result
    out: [ output_with_tabs ]



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
