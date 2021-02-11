#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

label: "extract other ncrnas!"

requirements:
  ScatterFeatureRequirement: {}
  SubworkflowFeatureRequirement: {}
  ShellCommandRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}

inputs:
  input_sequences: File
  cmsearch_file: File
  other_ncRNA_ribosomal_models: string[]
  name_string: string

outputs:
  ncrnas:
    type: File[]
    outputSource: gzip_files/compressed_file

steps:

  index_reads:
    run: ../../tools/RNA_prediction/easel/esl-sfetch-index.cwl
    in:
      sequences: input_sequences
    out: [ sequences_with_index ]

  extract_coords:
    run: ../../tools/RNA_prediction/extract-coords/extract-coords.cwl
    in:
      infernal_matches: cmsearch_file
      name: name_string
    out: [ matched_seqs_with_coords ]

  get_coords:
    run: ../../tools/RNA_prediction/pull_ncrnas/pull_ncrnas.cwl
    in:
      hits: extract_coords/matched_seqs_with_coords
      model: other_ncRNA_ribosomal_models
    out: [ matches ]

  get_ncrnas:
    run: ../../tools/RNA_prediction/easel/esl-sfetch-manyseqs.cwl
    scatter: names_contain_subseq_coords
    in:
      names_contain_subseq_coords: get_coords/matches
      indexed_sequences: index_reads/sequences_with_index
    out: [ sequences ]

  rename_ncrnas:
    run: ../../utils/move.cwl
    scatter: initial_file
    in:
      initial_file: get_ncrnas/sequences
      out_file_name:
        valueFrom: $(inputs.initial_file.nameroot.split("fasta_")[1]).fasta
    out: [ renamed_file ]

  gzip_files:
    run: ../../utils/pigz/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file: rename_ncrnas/renamed_file
    out: [compressed_file]


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














