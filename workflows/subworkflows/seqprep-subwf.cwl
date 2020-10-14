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
      - unzip_merged_reads/unzipped_merged_reads
      - unzip_single_reads/unzipped_merged_reads
    pickValue: first_non_null

steps:

# filter paired-end reads (for single do nothing)
  filter_paired:
    run: ../../tools/Raw_reads/filter_paired_reads/filter_paired_reads.cwl
    when: $(inputs.single == undefined)
    in:
      single: single_reads
      forward: forward_reads
      reverse: reverse_reads
      len: paired_reads_length_filter
    out: [ forward_filtered, reverse_filtered ]

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
    out: [ merged_reads, forward_unmerged_reads, reverse_unmerged_reads ]

# << unzip merged reads >>
  unzip_merged_reads:
    when: $(inputs.target_reads != undefined)
    run: ../../utils/multiple-gunzip.cwl
    in:
      target_reads: overlap_reads/merged_reads
      reads: { default: true }
    out: [ unzipped_merged_reads ]

# << unzipping single reads >>
  unzip_single_reads:
    run: ../../utils/multiple-gunzip.cwl
    when: $(inputs.target_reads != undefined)
    in:
      target_reads: single_reads
      reads: { default: true }
    out: [ unzipped_merged_reads ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
