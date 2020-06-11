#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: split FASTA by number of records
doc: based upon code by Maxim Scheremetjew, EMBL-EBI


requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 5000

hints:
  DockerRequirement:
    dockerPull: mgnify/pipeline-v5.dna_chunking:latest

inputs:
  seqs:
    # format: edam:format_1929  # collision with concatenate.cwl
    type: File
    inputBinding:
      position: 1
  chunk_size:
    type: int
    inputBinding:
      position: 2

baseCommand: [ esl-ssplit.pl ]

outputs:
  chunks:
    format: edam:format_1929  # FASTA
    type: File[]
    outputBinding:
      glob: "$(inputs.seqs.basename).*"

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schema.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"