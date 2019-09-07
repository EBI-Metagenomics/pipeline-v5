#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

#requirements:
# DockerRequirement:
#    dockerPull: alpine:3.7

inputs:
  input_fasta:
    label: fasta file (from esl) with all subunits
    type: File
    inputBinding:
      prefix: -i

  pattern_SSU:
    type: string
    inputBinding:
      prefix: -s
  pattern_LSU:
    type: string
    inputBinding:
      prefix: -l
  pattern_5S:
    type: string
    inputBinding:
      prefix: -f

baseCommand: get_subunits.py

outputs:
  SSU_seqs:
    type: File
    outputBinding:
      glob: "*SSU_extracted.fasta*"
  LSU_seqs:
    type: File
    outputBinding:
      glob: "*LSU_extracted.fasta*"

  5S_seqs:
    type: File
    outputBinding:
      glob: "*5S_extracted.fasta*"

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
s: author: Ekaterina Sakharova
