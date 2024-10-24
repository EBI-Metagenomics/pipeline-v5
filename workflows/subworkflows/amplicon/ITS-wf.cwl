#!/usr/bin/env cwl-runner

cwlVersion: v1.2
class: Workflow
label: "ITS SubWorkflow"

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}
  ResourceRequirement:
    ramMin: 5000
    ramMax: 10000
    coresMin: 4
#  SchemaDefRequirement:
#    types:
#      - $import: ../tools/biom-convert/biom-convert-table.yaml

inputs:
  query_sequences: File
  LSU_coordinates: File
  SSU_coordinates: File
  unite_database: {type: File, secondaryFiles: [.mscluster] }
  unite_taxonomy: string
  unite_otus: string
  itsone_database: {type: File, secondaryFiles: [.mscluster] }
  itsone_taxonomy: string
  itsone_otus: string
  otu_unite_label: string
  otu_itsone_label: string

outputs:

  masking_file:
    type: File?
    outputSource: gzip_masked_ITS/compressed_file

  unite_folder:
    type: Directory?
    outputSource: run_unite/out_dir

  itsonedb_folder:
    type: Directory?
    outputSource: run_itsonedb/out_dir

  number_ITS_seqs:
    type: int
    outputSource: count_ITS_seqs/count


# TODO: ADD QUALITY CONTROLLED READS

steps:

  cat:
    run: ../../../utils/concatenate.cwl
    in:
      files:
        - SSU_coordinates
        - LSU_coordinates
      outputFileName: { default: "SSU-and" }
      postfix: { default: "-LSU" }
    out: [ result ]

  #if proportion < 0.90 then carry on, update with potential "conditional"
  #mask SSU/LSU

  reformat_coords:
    run: ../../../tools/mask-for-ITS/format-bedfile.cwl
    in:
      all_coordinates: cat/result
    out: [ maskfile ]

  mask_for_ITS:
    run: ../../../tools/mask-for-ITS/bedtools.cwl
    in:
      sequences: query_sequences
      maskfile: reformat_coords/maskfile
    out: [masked_sequences]

  gzip_masked_ITS:
    run: ../../../utils/pigz/gzip.cwl
    in:
      uncompressed_file: mask_for_ITS/masked_sequences
    out: [ compressed_file ]

#run unite and ITSonedb

  count_masked_fasta:
    run: ../../../utils/count_fasta.cwl
    in:
      sequences: mask_for_ITS/masked_sequences
      number: { default: 1 }
    out: [ count ]

  run_unite:
    when: $(inputs.fasta_count > 0)
    run: ../classify-otu-visualise.cwl
    in:
      fasta_count: count_masked_fasta/count
      fasta: mask_for_ITS/masked_sequences
      mapseq_ref: unite_database
      mapseq_taxonomy: unite_taxonomy
      otu_ref: unite_otus
      otu_label: otu_unite_label
      return_dirname: {default: 'unite'}
      file_for_prefix: query_sequences
    out: [ out_dir ]

  run_itsonedb:
    when: $(inputs.fasta_count > 0)
    run: ../classify-otu-visualise.cwl
    in:
      fasta_count: count_masked_fasta/count
      fasta: mask_for_ITS/masked_sequences
      mapseq_ref: itsone_database
      mapseq_taxonomy: itsone_taxonomy
      otu_ref: itsone_otus
      otu_label: otu_itsone_label
      return_dirname: {default: 'itsonedb'}
      file_for_prefix: query_sequences
    out: [ out_dir ]

# count IPS seqs
  count_ITS_seqs:
    run: ../../../utils/count_fasta.cwl
    in:
      sequences: mask_for_ITS/masked_sequences
      number: { default: 1 }
    out: [ count ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
