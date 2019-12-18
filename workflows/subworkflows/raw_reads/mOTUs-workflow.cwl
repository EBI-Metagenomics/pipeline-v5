#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: Subworkflow for mOTUs classification

requirements:
    SubworkflowFeatureRequirement: {}
    InlineJavascriptRequirement: {}

inputs:
    reads: File

outputs:
  motus:
    type: File
    outputSource: clean_classification/clean_annotations

steps:

  clean_fasta_headers:
    run: ../../../utils/clean_fasta_headers.cwl
    in:
      sequences: reads
    out: [ sequences_with_cleaned_headers ]

  motus_classification:
    run: ../../../tools/Raw_reads/mOTUs/mOTUs.cwl
    in:
      reads: clean_fasta_headers/sequences_with_cleaned_headers
    out: [ motu_taxonomy ]

  clean_classification:
    run: ../../../tools/Raw_reads/mOTUs/clean_motus_output.cwl
    in:
      taxonomy: motus_classification/motu_taxonomy
    out: [ clean_annotations ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.18.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:author': 'Varsha Kale'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"

