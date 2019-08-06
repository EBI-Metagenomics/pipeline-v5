class: Workflow
cwlVersion: v1.0

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  input_fasta_file:  # input assembly fasta
    type: File

  virsorter_data:
    type: Directory
    default:
      class: Directory
      path:  ../tools/Viral/VirSorter/virsorter-data


outputs:
  output_length_filtering:
    outputSource: length_filter/filtered_contigs_fasta
    type: File
  output_virfinder:
    outputSource: virfinder/output
    type: File
  output_virsorter:
    outputSource: virsorter/predicted_viral_seq_dir
    type: Directory
  output_parse:
    outputSource: parse_pred_contigs/output_fastas
    type:
      type: array
      items: File
  output_parse_stdout:
    outputSource: parse_pred_contigs/stdout
    type: File
  output_parse_stderr:
    outputSource: parse_pred_contigs/stderr
    type: File


steps:
  length_filter:
    in:
      fasta_file: input_fasta_file
    out:
      - filtered_contigs_fasta
    run: ../tools/Viral/LengthFiltering/length_filtering.cwl

  virfinder:
    in:
      fasta_file: length_filter/filtered_contigs_fasta
    out:
      - output
    run: ../tools/Viral/VirFinder/virfinder.cwl
    label: "VirFinder: R package for identifying viral sequences from metagenomic data using sequence signatures"

  virsorter:
    in:
      data: virsorter_data
      fasta_file: length_filter/filtered_contigs_fasta
    out:
      - predicted_viral_seq_dir
    run: ../tools/Viral/VirSorter/virsorter.cwl
    label: "VirSorter: mining viral signal from microbial genomic data"

  parse_pred_contigs:
    in:
      assembly: length_filter/filtered_contigs_fasta
      virfinder_tsv: virfinder/output
      virsorter_dir: virsorter/predicted_viral_seq_dir
    out:
      - output_fastas
      - stdout
      - stderr
    run: ../tools/Viral/ParsingPredictions/parse_viral_pred.cwl