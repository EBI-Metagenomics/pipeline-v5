cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 200  # just a default, could be lowered

hints:
  DockerRequirement:
    dockerPull: alpine:3.7

inputs:
  fasta:
    type: File
    format: edam:format_1929
    inputBinding:
      prefix: -f

baseCommand: [ run_samtools.sh ]

outputs:
  fasta_index:
    type: File
    outputBinding:
      glob: "index/$(inputs.fasta.basename).bgz.fai"
  bgz_index:
    type: File
    outputBinding:
      glob: "index/$(inputs.fasta.basename).bgz.gzi"
  fasta_bgz:
    type: File
    outputBinding:
      glob: "index/$(inputs.fasta.basename).bgz"

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"