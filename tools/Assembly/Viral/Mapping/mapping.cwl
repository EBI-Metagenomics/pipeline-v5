#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Viral contig mapping"

requirements:
  DockerRequirement:
    dockerPull: mapping_viral_predictions:latest
  InlineJavascriptRequirement: {}

baseCommand: ['Rscript', '/Make_viral_contig_map.R']
arguments: ["-o", $(inputs.input_table.nameroot)_mapping_results]

inputs:
  input_table:
    type: File
    inputBinding:
      separate: true
      prefix: "-t"

stderr: stderr.txt
stdout: stdout.txt

outputs:
  stdout: stdout
  stderr: stderr

  folder:
    type: Directory
    outputBinding:
      glob: $(inputs.input_table.nameroot)_mapping_results

  #mapping_results:
  #  type:
  #    type: array
  #    items: File
  #  outputBinding:
  #    glob: $(inputs.outdir+"/"+"*.pdf")
