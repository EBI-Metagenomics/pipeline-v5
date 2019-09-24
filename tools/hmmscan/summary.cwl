#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

#requirements:
#  DockerRequirement:
#    dockerPull: alpine:3.9.4

baseCommand: [summary_hmm.sh]

inputs:
  hmm_tab_results:
    type: File
    inputBinding:
      prefix: -i

outputs:
  hmmscan_summary:
    type: File
    outputBinding:
      glob: '*summary.ko'
