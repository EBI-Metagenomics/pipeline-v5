cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

hints:
  DockerRequirement:
    dockerPull: biopython/biopython:latest

inputs:
  input_table:
    type: File
    inputBinding:
      prefix: '-i'

baseCommand: [ hmmscan_tab.py ]  # old was with sed

arguments:
  - valueFrom: $(inputs.input_table.nameroot).tsv
    prefix: -o

outputs:
  output_with_tabs:
    type: File
    outputBinding:
      glob: "*.tsv"
