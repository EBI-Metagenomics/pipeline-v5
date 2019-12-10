#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# this script returns LSU, SSU coords

requirements:
  ResourceRequirement:
    ramMin: 8000
    coresMin: 8

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

baseCommand: get_subunits_coords.py

stdout: stdout.txt

outputs:
  stdout: stdout

  SSU_seqs:
    type: File
    outputBinding:
      glob: "*SSU*"
  LSU_seqs:
    type: File
    outputBinding:
      glob: "*LSU*"
  counts:
    type: File
    outputBinding:
      glob: "RNA-counts"

hints:
  - class: DockerRequirement
    dockerPull: alpine:3.7

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"

