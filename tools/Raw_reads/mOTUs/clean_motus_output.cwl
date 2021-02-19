#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ShellCommandRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 200

label: "remove empty rows and reformat motus"

inputs:
  taxonomy:
    type: File
    format: edam:format_3746
    label: motus classification
    inputBinding:
        position: 1

baseCommand: [clean_motus_output.sh]

outputs:
  clean_annotations:
    type: File
    outputBinding:
        glob: "*.tsv"

hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.bash-scripts:v1.3


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"

