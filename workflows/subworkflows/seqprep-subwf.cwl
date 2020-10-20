#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.2.0-dev2

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
    forward_reads: File?
    reverse_reads: File?
    single_reads: File?
    paired_reads_length_filter: int

outputs:
  unzipped_single_reads:
    type: File
    outputSource:
      - unzip_merged_reads/unzipped_file
      - unzip_single_reads/unzipped_file
    pickValue: first_non_null

  count_forward_submitted_reads:
    type: File
    outputSource: count_submitted_reads/count

steps:

# << unzipping paired reads >>
  unzip_forward_reads:
    run: ../../utils/multiple-gunzip.cwl
    when: $(inputs.single == undefined)
    in:
      single: single_reads
      target_reads: forward_reads
      reads: { default: true }
    out: [ unzipped_file ]

  unzip_reverse_reads:
    run: ../../utils/multiple-gunzip.cwl
    when: $(inputs.single == undefined)
    in:
      single: single_reads
      target_reads: reverse_reads
      reads: { default: true }
    out: [ unzipped_file ]

  count_submitted_reads:
    run: ../../utils/count_lines/count_lines.cwl
    when: $(inputs.single == undefined)
    in:
      single: single_reads
      sequences: unzip_forward_reads/unzipped_file
      number: { default: 4 }
    out: [ count ]

# filter paired-end reads (for single do nothing)
  filter_paired:
    run: ../../tools/Raw_reads/filter_paired_reads/filter_paired_reads.cwl
    when: $(inputs.single == undefined)
    in:
      single: single_reads
      forward: unzip_forward_reads/unzipped_file
      reverse: unzip_reverse_reads/unzipped_file
      len: paired_reads_length_filter
    out: [ forward_filtered, reverse_filtered ]  # unzipped

# << SeqPrep only for paired reads >>
  overlap_reads:
    label: Paired-end overlapping reads are merged
    run: ../../tools/SeqPrep/seqprep.cwl
    when: $(inputs.single == undefined)
    in:
      single: single_reads
      forward_reads: filter_paired/forward_filtered
      reverse_reads: filter_paired/reverse_filtered
      namefile: forward_reads
    out: [ merged_reads, forward_unmerged_reads, reverse_unmerged_reads ]  # compressed

# << unzip merged reads >>
  unzip_merged_reads:
    when: $(inputs.target_reads != undefined)
    run: ../../utils/multiple-gunzip.cwl
    in:
      target_reads: overlap_reads/merged_reads
      reads: { default: true }
    out: [ unzipped_file ]

# << unzipping single reads >>
  unzip_single_reads:
    run: ../../utils/multiple-gunzip.cwl
    when: $(inputs.target_reads != undefined)
    in:
      target_reads: single_reads
      reads: { default: true }
    out: [ unzipped_file ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
