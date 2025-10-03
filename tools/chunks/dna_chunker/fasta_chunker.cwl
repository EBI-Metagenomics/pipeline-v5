#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: split FASTA by number of records
doc: based upon code by Maxim Scheremetjew, EMBL-EBI


requirements:
  InitialWorkDirRequirement:
    listing: [$(inputs.seqs)]
  ResourceRequirement:
    coresMax: 1
    ramMin: 25000

hints:
  DockerRequirement:
    dockerPull: mgnify/pipeline-v5.dna_chunking:latest

inputs:

  number_of_output_files:
    type: string  # boolean for esl-ssplit.pl
    inputBinding:
      position: 1
      # prefix: "-n"  # uncomment for esl-ssplit.pl

  same_number_of_residues:
    type: string # boolean for esl-ssplit.pl
    inputBinding:
      position: 2
      # prefix: "-r"  # uncomment for esl-ssplit.pl

  seqs:
    type: File
    inputBinding:
      position: 3

  chunk_size:
    type: int
    inputBinding:
      position: 4


baseCommand: [ esl-ssplit.sh ]

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
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"