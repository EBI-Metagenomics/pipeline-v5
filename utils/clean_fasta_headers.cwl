#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: Replaces problematic characters from FASTA headers with dashes

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered
  InlineJavascriptRequirement: {}

inputs:
  sequences:
    type: File
    # streamable: true
    # <<doesn't support by cwltoil>> format: [ edam:format_1929, edam:format_1930]  # FASTA or FASTQ

stdin: $(inputs.sequences.path)

baseCommand: [ tr, '" /|<_;#"', '-------' ]

stdout: $(inputs.sequences.nameroot).unfiltered_fasta

outputs:
  sequences_with_cleaned_headers:
    type: stdout
    # format: $(inputs.sequences.format)

hints:
  - class: DockerRequirement
    dockerPull: 'alpine:3.7'

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

's:license': "https://www.apache.org/licenses/LICENSE-2.0"
's:copyrightHolder': "EMBL - European Bioinformatics Institute"