#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: mask SSU and LSU coorindates with bedtools for ITS
doc: "https://bedtools.readthedocs.io/en/latest/content/tools/maskfasta.html"

requirements:
 DockerRequirement:
   dockerPull: quay.io/biocontainers/bedtools:2.28.0--hdf88d34_0

inputs:
  sequences:
    type: File
    inputBinding:
      position: 1
      prefix: -fi
    label: Input fasta file.
    format: edam:format_1929  # FASTA

  maskfile:
    type: File
    inputBinding:
      position: 3
      prefix: -bed
    label: maskfile
    format: edam:format_3475  # TSV

baseCommand: [bedtools, maskfasta]

arguments:
  - valueFrom: masked-for-ITS.fasta
    prefix: -fo

outputs:
  masked_sequences:
    type: File
    format: edam:format_1929  # FASTA
    outputBinding:
      glob: masked-for-ITS.fasta

$namespaces:
  edam: http://edamontology.org/
  s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"