#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

# FIXME: this script needs some documentation
label: "reformat antiSMASH"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 200

baseCommand: [reformat_antismash.py]

inputs:
  glossary:
    type: string
    inputBinding:
      position: 1
      prefix: -g
  geneclusters:
    type: File
    inputBinding:
        position: 2
        prefix: -a

outputs:
  reformatted_clusters:
    type: File
    outputBinding:
      glob: geneclusters-summary.txt

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:copyrightHolder:
  - class: s:Organization
    s:name: "EMBL - European Bioinformatics Institute"
    s:url: "https://www.ebi.ac.uk"
