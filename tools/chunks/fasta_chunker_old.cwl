#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: split FASTA by number of records
doc: based upon code by Maxim Scheremetjew, EMBL-EBI

requirements:
  ResourceRequirement:
    coresMax: 8
    ramMin: 10000  # just a default, could be lowered
hints:
  SoftwareRequirement:
    packages:
      biopython:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_007173" ]
        version: [ "1.65", "1.66", "1.69" ]

inputs:
  seqs:
    type: File
    format: edam:format_1929  # FASTA
  chunk_size: int

baseCommand: python

arguments:
  - prefix: -c
    valueFrom: |
      from Bio import SeqIO
      currentSequences = []
      for record in SeqIO.parse("$(inputs.seqs.path)", "fasta"):
          currentSequences.append(record)
          if len(currentSequences) == $(inputs.chunk_size):
              fileName = currentSequences[0].id + "_" + \\
                             currentSequences[-1].id + ".fasta"
              for char in [ "/", " ", ":" ]:
                  fileName = fileName.replace(char, "_")
              SeqIO.write(currentSequences, "$(runtime.outdir)/"+fileName, "fasta")
              currentSequences = []

      # write any remaining sequences
      if len(currentSequences) > 0:
          fileName = currentSequences[0].id + "_" + \\
                         currentSequences[-1].id + ".fasta"
          for char in [ "/", " ", ":" ]:
              fileName = fileName.replace(char, "_")
          SeqIO.write(currentSequences, "$(runtime.outdir)/"+fileName, "fasta")

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

