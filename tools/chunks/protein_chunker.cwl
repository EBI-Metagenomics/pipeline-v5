#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: split FAA by number of records
doc: based upon code by Maxim Scheremetjew, EMBL-EBI


requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 8000
  ShellCommandRequirement: {}

hints:
  DockerRequirement:
    dockerPull: 'alpine:3.7'

  SoftwareRequirement:
    packages:
      biopython:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_007173" ]
        version: [ "1.65", "1.66", "1.69" ]

inputs:
  seqs:
    # format: edam:format_1929  # collision with concatenate.cwl
    type: File
    inputBinding:
      prefix: -i
  chunk_size:
    type: int
    inputBinding:
      prefix: -s
  file_format:
    type: string?
    inputBinding:
      prefix: -f

arguments:
  - valueFrom: '> /dev/null'
    shellQuote: false
    position: 10
  - valueFrom: '2> /dev/null'
    shellQuote: false
    position: 11


baseCommand: [ split_to_chunks.py ]

outputs:
  chunks:
    format: edam:format_1929  # FASTA
    type: File[]
    outputBinding:
      glob: '*_*'

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"