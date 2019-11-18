#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# In fasta mode:
# this script returns LSU, SSU, 5S, 5.8S and models fasta-s.gz

requirements:
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
  pattern_5.8S:
    type: string?
    inputBinding:
      prefix: -e
  prefix:
    type: string?
    inputBinding:
      prefix: -p


baseCommand: get_subunits.py

stdout: stdout.txt

outputs:
  stdout: stdout

  SSU_seqs:
    type: File
    outputBinding:
      glob: "sequence-categorisation/*SSU.fasta*"
  LSU_seqs:
    type: File
    outputBinding:
      glob: "sequence-categorisation/*LSU.fasta*"

  fastas:
    type: File[]
    outputBinding:
      glob: "sequence-categorisation/*.fa"

  sequence-categorisation:
    type: Directory?
    outputBinding:
      glob: "sequence-categorisation"

hints:
  - class: DockerRequirement
    dockerPull: alpine:3.7

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"

