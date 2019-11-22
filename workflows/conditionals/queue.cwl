cwlVersion: v1.0
class: CommandLineTool

baseCommand:
  - env

requirements:
  EnvVarRequirement:
    envDef:
      TOIL_LSF_ARGS: $(inputs.message)

inputs:
  - id: message
    type: string
#    inputBinding:
#      position: 0

outputs:
  example_out:
    type: stdout

stdout: output.txt

#arguments:
#  - position: 1
#    valueFrom: $(inputs.infile.nameroot).out
#outputs:
#  - id: outfile
#    type: File
#    outputBinding:
#      glob: $(inputs.infile.nameroot).out
