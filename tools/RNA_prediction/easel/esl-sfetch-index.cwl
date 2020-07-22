#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool
label: index a sequence file for use by esl-sfetch
doc: "https://github.com/EddyRivasLab/easel"

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/hmmer:3.2.1--hf484d3e_1

baseCommand: [ esl-index.sh ]

requirements:
  ResourceRequirement:
    coresMin: 4
    ramMin: 5000
  InitialWorkDirRequirement:
    listing:
        - $(inputs.sequences)

inputs:
  sequences:
    type: File
    format: edam:format_1929  # FASTA
    inputBinding:
      prefix: -f
      position: 1
      valueFrom: $(self.basename)
    label: Input fasta file.

outputs:
  sequences_with_index:
    type: File
    secondaryFiles:
        - .ssi
    outputBinding:
      glob: "folder/$(inputs.sequences.basename)"
    label: The index file
    format: edam:format_1929  # FASTA

$namespaces:
  edam: http://edamontology.org/
  s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

's:license': "https://www.apache.org/licenses/LICENSE-2.0"
's:copyrightHolder': "EMBL - European Bioinformatics Institute"