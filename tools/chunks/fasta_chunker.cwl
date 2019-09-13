#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: split FASTA by number of records
doc: based upon code by Maxim Scheremetjew, EMBL-EBI
#copied from ebi-metagenomics-cwl/tools/fasta_chunker.cwl


requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered
hints:
  SoftwareRequirement:
    packages:
      biopython:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_007173" ]
        version: [ "1.65", "1.66", "1.69" ]

inputs:
  seqs:
    type: File
    inputBinding:
      prefix: -i
  chunk_size:
    type: int
    inputBinding:
      prefix: -s

baseCommand: [ split_to_chunks.py ]

arguments:
  - prefix: -c
    valueFrom: |


outputs:
  chunks:
    format: edam:format_1929  # FASTA
    type: File[]
    outputBinding:
      glob: '*'

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"