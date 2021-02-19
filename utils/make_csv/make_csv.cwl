cwlVersion: v1.0
class: CommandLineTool
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 200  # just a default, could be lowered

baseCommand: [ make_csv.py ]

inputs:
  tab_sep_table:
    format: edam:format_3475
    type: File
    inputBinding:
      prefix: '-i'
  output_name:
    type: string
    inputBinding:
      prefix: '-o'

outputs:
  csv_result:
    type: File
    format: edam:format_3752
    outputBinding:
      glob: $(inputs.output_name)

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.python3:v3.1

$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
