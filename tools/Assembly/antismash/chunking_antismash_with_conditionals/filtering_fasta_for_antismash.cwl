class: Workflow
cwlVersion: v1.2.0-dev2

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

  fasta: File
  contig_min_limit: int

outputs:
  filtered_fasta_for_antismash:
    type: File
    outputSource: filter_contigs_antismash/filtered_file
  count_after_filtering:
    type: int
    outputSource: count_reads_after_filtering/count

steps:

# << count reads pre QC >>
  count_reads:
    in:
      sequences: fasta
      number: { default: 1 }
    out: [ count ]
    run: ../../../../utils/count_fasta.cwl

  filter_contigs_antismash:
    run: ../../../qc-filtering/qc-filtering.cwl
    in:
      seq_file: fasta
      min_length: contig_min_limit
      submitted_seq_count: count_reads/count
      stats_file_name: { default: 'qc_summary_antismash' }
      input_file_format: { default: fasta }
    out: [filtered_file]

  count_reads_after_filtering:
    in:
      sequences: filter_contigs_antismash/filtered_file
      number: { default: 1 }
    out: [ count ]
    run: ../../../../utils/count_fasta.cwl
