cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: 'alpine:3.7'
  ResourceRequirement:
    coresMin: 1
    ramMin: 1000

baseCommand: [ "touch" ]

inputs:
  filename:
    type: string
    inputBinding:
      position: 1

outputs:
  created_file:
    type: File
    outputBinding:
      glob: $(inputs.filename)