#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: "merges output of seqprep and unzips for paired end reads, or unzips file for single end"
requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

hints:
 SoftwareRequirement:
   packages: { gunzip }

inputs:
 merged_reads:
   type: File?
#   format: edam:format_1930  # FASTQ
   inputBinding: { position: 3 }
   label: "merged seq prep output"
 forward_unmerged_reads:
   type: File
#   format: edam:format_1930  # FASTQ
   inputBinding: { position: 1 }
   label: "unmerged forward seqprep output or single end reads"
 reverse_unmerged_reads:
   type: File?
#   format: edam:format_1930  # FASTQ
   inputBinding: { position: 2 }
   label: " unmerged reverse seqprep output"

baseCommand: [ gunzip, -c ]

stdout: unzipped_merged_reads  # helps with cwltool's --cache

outputs:
  unzipped_merged_reads:
    type: stdout
    label: "merged and/or unzipped fastq files"
#    format: edam:format_1930  # FASTQ

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
