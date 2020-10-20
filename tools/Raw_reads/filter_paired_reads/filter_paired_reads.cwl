#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "remove reads from both files that are less than LEN"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 200

inputs:
  forward:
    type: File
    format: edam:format_1930
    inputBinding:
        prefix: -f
  reverse:
    type: File
    format: edam:format_1930
    inputBinding:
        prefix: -r
  len:
    type: int
    inputBinding:
        prefix: -l

baseCommand: [filter_paired_reads_uncompressed.sh]

outputs:
  forward_filtered:
    type: File
    format: edam:format_1930
    outputBinding:
        glob: forward_filt.fastq
  reverse_filtered:
    type: File
    format: edam:format_1930
    outputBinding:
        glob: reverse_filt.fastq

hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.filter-paired


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:   "EMBL - European Bioinformatics Institute"