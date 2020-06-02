#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# this script returns LSU, SSU coords

requirements:
  ResourceRequirement:
    ramMin: 200
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
    dockerPull: mgnify/pipeline-v5.python3:latest

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"

