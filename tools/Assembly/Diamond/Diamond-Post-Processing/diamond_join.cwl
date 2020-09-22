#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Script do join of prepared uniref90 DB and Diamond annotations"

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 200

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.bash-scripts:v1.1

baseCommand: [diamond_post_run_join.sh]

inputs:
  input_diamond:
    format: edam:format_2333
    type: File
    inputBinding:
      separate: true
      prefix: -i
  input_db:
    type: [string, File]
    inputBinding:
      separate: true
      prefix: -d
  filename: string

stdout: $(inputs.filename)_summary.diamond.without_header

outputs:
  output_join:
    type: stdout
    format: edam:format_2333


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: 'Ekaterina Sakharova, Maxim Scheremetjew'
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"