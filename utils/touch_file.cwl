cwlVersion: v1.0
class: CommandLineTool

hints:
  DockerRequirement:
    dockerPull: ubuntu:latest
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