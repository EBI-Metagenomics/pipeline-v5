cwlVersion: v1.0
class: CommandLineTool

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
  fastq:
    type: File
    streamable: true
    format: edam:format_1930  # FASTQ

stdin: $(inputs.fastq.path)

baseCommand: [ python ]

arguments:
  - valueFrom: |
      import sys
      from Bio import SeqIO
      SeqIO.convert(sys.stdin, "fastq", sys.stdout, "fasta")
    prefix: -c

stdout: $(inputs.fastq.basename).fasta  # helps with cwltool's cache

outputs:
  fasta:
    type: stdout
    format: edam:format_1929  # FASTA

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"