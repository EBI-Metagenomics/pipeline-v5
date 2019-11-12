#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "antiSMASH"

requirements:
  InlineJavascriptRequirement: {}

hints:
  DockerRequirement:
    dockerPull: 'alpine:3.7'

inputs:
  outdirname:
    type: string
    inputBinding:
      position: 1
      prefix: -o # --outputfolder

  input_fasta:
    type: File
    inputBinding:
      # position: 9
      prefix: -i

baseCommand: [run_antismash.sh]

#arguments:
#  - valueFrom: --knownclusterblast
#    position: 2
#  - valueFrom: "-v"
#    position: 3
#  - valueFrom: --smcogs
#    position: 4
#  - valueFrom: --transatpks_da
#    position: 5
#  - valueFrom: --borderpredict
#    position: 6
#  - valueFrom: --asf
#    position: 7
#  - valueFrom: --inclusive
#    position: 8

stdout: stdout.txt
stderr: stderr.txt

outputs:
  stdout: stdout
  stderr: stderr

  final_gbk:
    type: File
    outputBinding:
      glob: $(inputs.outdirname)/*final.gbk
  final_embl:
    type: File
    outputBinding:
      glob: $(inputs.outdirname)/*final.embl
  geneclusters_js:
    type: File
    outputBinding:
      glob: $(inputs.outdirname)/geneclusters.js
  geneclusters_txt:
    type: File
    outputBinding:
      glob: $(inputs.outdirname)/geneclusters.txt