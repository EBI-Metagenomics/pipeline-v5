#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: split FASTA by number of records
doc: based upon code by Maxim Scheremetjew, EMBL-EBI


requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1000  # just a default, could be lowered
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

baseCommand: [ "/hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda3-4.6.14/bin/python3", "/hps/nobackup2/production/metagenomics/pipeline/testing/kate/pipeline-v5/tools/chunks/split_to_chunks.py" ]

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
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"