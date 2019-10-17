#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

#requirements:
#  DockerRequirement:
#    dockerPull: linux_docker_diamond:latest

baseCommand: [diamond_post_run_join.sh]

inputs:
  input_diamond:
    type: File
    inputBinding:
      separate: true
      prefix: -i
  input_db:
    type: File
    inputBinding:
      separate: true
      prefix: -d
  filename: File

stdout: $(inputs.filename.nameroot)_summary.diamond.without_header

outputs:
  output_join:
    type: stdout