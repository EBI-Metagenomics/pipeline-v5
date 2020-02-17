#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "antiSMASH"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 80
    ramMin: 40000

hints:
  DockerRequirement:
    dockerPull: 'alpine:3.7'

inputs:

  outdirname:
    type: string
    inputBinding:
      prefix: -o

  input_fasta:
    type: File
    inputBinding:
      prefix: -i

  glossary:
    type: File
    inputBinding:
      prefix: -g

  outname:
    type: string
    inputBinding:
      prefix: -n

  final_folder:
    type: string
    inputBinding:
      prefix: -f

baseCommand: [run_antismash.sh]

stdout: stdout.txt
stderr: stderr.txt

outputs:
  antismash_in_folder:
    type: Directory
    outputBinding:
      glob: $(inputs.final_folder)

  stdout: stdout
  stderr: stderr

  reformated_clusters:
    type: File?
    outputBinding:
      glob: $(inputs.final_folder)/$(inputs.outname)_antismash_geneclusters.txt
