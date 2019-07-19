#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: replace problem characters from FASTA headers with dashes

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered

inputs:
  sequences:
    type: File
    streamable: true
    format: edam:format_1929  # FASTA

stdin: $(inputs.sequences.path)

baseCommand: [ tr, ' /|<_;#', '-------' ]

stdout: $(inputs.sequences.nameroot).cleaned.fasta

outputs:
  sequences_with_cleaned_headers:
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