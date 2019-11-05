#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: Subworkflow for mOTUs classification

requirements:
  - class: InlineJavascriptRequirement
#  - class: SchemaDefRequirement
#    types:
#        - $import: ../tools/biom-convert/biom-convert-table.yaml

inputs:
    reads: File
    fastq_count: int

outputs:
  motus_biom:
    type: File
    outputSource: motus_classification/motu_taxonomy

steps:

  trim_quality_control:
    doc: |
      Low quality trimming (low quality ends and sequences with < quality scores
      less than 15 over a 4 nucleotide wide window are removed)
    run: ../../../tools/Trimmomatic/Trimmomatic-v0.36-SE.cwl
    in:
      reads1: reads
      phred: { default: '33' }
      leading: { default: 3 }
      trailing: { default: 3 }
      end_mode: { default: SE }
      minlen: { default: 100 }
      slidingwindow: { default: '4:15' }
    out: [reads1_trimmed]

  clean_fasta_headers:
    run: ../../../utils/clean_fasta_headers.cwl
    in:
      sequences: trim_quality_control/reads1_trimmed
    out: [ sequences_with_cleaned_headers ]

  run_quality_control_filtering:
    run: ../../../tools/qc-filtering/qc-filtering.cwl
    in:
      seq_file: clean_fasta_headers/sequences_with_cleaned_headers
      submitted_seq_count: fastq_count
      stats_file_name: {default: 'fastq_qc_summary'}
      min_length: { default: 100 }
      input_file_format: { default: 'fastq' }
    out: [ filtered_file, stats_summary_file ]

  motus_classification:
    run: ../../../tools/mOTUs/mOTUs.cwl
    in:
      reads: run_quality_control_filtering/filtered_file
    out: [ motu_taxonomy ]


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.18.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:author': 'Varsha Kale'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"
