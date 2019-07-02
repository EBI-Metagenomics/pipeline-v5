#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
requirements:
  DockerRequirement:
    dockerPull: linux_docker_diamond:latest

baseCommand: ["bash", "/run_join.sh"]

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

stdout: $(inputs.input_diamond.nameroot)_join

outputs:
  output_join:
    type: stdout