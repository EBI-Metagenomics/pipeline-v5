#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "gather summary file from InterProScan"

requirements:
  ResourceRequirement:
    ramMin: 300

hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.python3:v1

inputs:
  antismash_summary:
    type: File?
    inputBinding:
      prefix: -a
  folder_name:
    type: string
    inputBinding:
      prefix: -f

baseCommand: [ move_antismash_summary.py ]

outputs:
  summary_in_folder:
    type: Directory
    outputBinding:
        glob: $(inputs.folder_name)

$namespaces:
 s: http://schema.org/
 iana: https://www.iana.org/assignments/media-types/
$schemas:
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"

