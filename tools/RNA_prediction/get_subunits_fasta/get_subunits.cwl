#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# In fasta mode:
# this script returns LSU, SSU, 5S, 5.8S and models fasta-s.gz

hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.python3:v3.1
requirements:
  ResourceRequirement:
    ramMin: 200
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
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: "sequence-categorisation/*SSU.fasta*"
  LSU_seqs:
    type: File
    format: edam:format_1929  # FASTA
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

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: 'Ekaterina Sakharova, Varsha Kale'
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"