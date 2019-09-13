#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
# DockerRequirement:
#    dockerPull: alpine:3.7
  ResourceRequirement:
    ramMin: 25000
    ramMax: 25000
    coresMin: 2

inputs:
  input:
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
    type: string?
    inputBinding:
      prefix: -f

  mode:
    type: string
    inputBinding:
      prefix: -m

baseCommand: get_subunits.py

outputs:
  SSU_seqs:
    type: File
    outputBinding:
      glob: "*SSU*"
  LSU_seqs:
    type: File
    outputBinding:
      glob: "*LSU*"

  5S_seqs:
    type: File?
    outputBinding:
      glob: "*5S_extracted.fasta*"

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"

