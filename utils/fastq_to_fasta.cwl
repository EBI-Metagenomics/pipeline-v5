cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

hints:
  DockerRequirement:
    dockerPull: biopython/biopython:latest
  SoftwareRequirement:
    packages:
      biopython:
        specs: [ "https://identifiers.org/rrid/RRID:SCR_007173" ]
        version: [ "1.65", "1.66", "1.69" ]

inputs:
  fastq:
    type: File
    inputBinding:
      prefix: '-i'

arguments:
  - valueFrom: $(inputs.fastq.nameroot).unclean
    prefix: '-o'

baseCommand: [ fastq_to_fasta.py ]

outputs:
  fasta:
    type: File
    # format: edam:format_1929
    outputBinding:
      glob: "*.unclean"

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"