cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 200  # just a default, could be lowered

baseCommand: [ make_csv.py ]

inputs:
  tab_sep_table:
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
    outputBinding:
      glob: $(inputs.output_name)

hints:
  DockerRequirement:
    dockerPull: alpine:3.7

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"