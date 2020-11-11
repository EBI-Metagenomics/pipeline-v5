#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

label: mask SSU and LSU coorindates with bedtools for ITS

doc: "https://bedtools.readthedocs.io/en/latest/content/tools/maskfasta.html"

requirements:
  ResourceRequirement:
    coresMin: 4
    ramMin: 200

hints:
 DockerRequirement:
   dockerPull: microbiomeinformatics/pipeline-v5.bedtools:v2.28.0

baseCommand: [bedtools, maskfasta]

inputs:
  sequences:
    type: File
    inputBinding:
      position: 1
      prefix: -fi
    label: Input fasta file.

  maskfile:
    type: File
    inputBinding:
      position: 3
      prefix: -bed
    label: maskfile

arguments:
  - valueFrom: ITS_masked.fasta
    prefix: -fo

outputs:
  masked_sequences:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: ITS_masked.fasta

$namespaces:
  edam: http://edamontology.org/
  s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
