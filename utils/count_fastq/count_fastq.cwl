#!/usr/bin/env
cwlVersion: v1.0
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

class: CommandLineTool
requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMin: 2
    ramMin: 200  # just a default, could be lowered
    # outdirMax: 5000
hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.7'

inputs:
  sequences:
    type: File
    # streamable: true
    # format: edam:format_1930  # FASTQ

baseCommand: [ bash ]

arguments:
  - valueFrom: |
      expr \$(cat $(inputs.sequences.path) | wc -l) / 4
    prefix: -c

stdout: count

outputs:
  count:
    type: int
    outputBinding:
      glob: count
      loadContents: true
      outputEval: $(Number(self[0].contents))

$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:license': "https://www.apache.org/licenses/LICENSE-2.0"
's:copyrightHolder': "EMBL - European Bioinformatics Institute"
