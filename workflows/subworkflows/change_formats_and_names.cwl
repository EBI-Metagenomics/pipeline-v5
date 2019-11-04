#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  genome_properties_summary: File
  kegg_summary: File
  antismash_gbk: File
  antismash_embl: File
  fasta: File

outputs:
  gp_summary_csv:
    type: File
    outputSource: create_csv_gp/csv_result
  kegg_summary_csv:
    type: File
    outputSource: create_csv_kp/csv_result
  antismash_gbk:
    type: File
    outputSource: move_antismash_gbk/renamed_file
  antismash_embl:
    type: File
    outputSource: move_antismash_embl/renamed_file

steps:

# change TSV to CSV for genome_properties
  create_csv_gp:
    run: ../../utils/make_csv.cwl
    in:
      tab_sep_table: genome_properties_summary
      output_name:
        source: genome_properties_summary
        valueFrom: $(self.nameroot.split('SUMMARY_FILE_')[1])
    out: [csv_result]

# change TSV to CSV for kegg_pathways
  create_csv_kp:
    run: ../../utils/make_csv.cwl
    in:
      tab_sep_table: kegg_summary
      output_name:
        source: kegg_summary
        valueFrom: $(self.nameroot)
    out: [csv_result]

# rename (move) antismash gbk
  move_antismash_gbk:
    run: ../../utils/move.cwl
    in:
      initial_file: antismash_gbk
      out_file_name:
        source: fasta
        valueFrom: $(self.nameroot)_antismash_final.gbk
    out: [renamed_file]

# rename (move) antismash embl
  move_antismash_embl:
    run: ../../utils/move.cwl
    in:
      initial_file: antismash_embl
      out_file_name:
        source: fasta
        valueFrom: $(self.nameroot)_antismash_final.embl
    out: [renamed_file]