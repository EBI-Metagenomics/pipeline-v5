#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "antiSMASH"

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 1
    ramMin: 35000

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

  final_gbk:
    type: File?
    outputBinding:
      glob: $(inputs.final_folder)/$(inputs.outname)_antismash_final.gbk.gz
  final_embl:
    type: File?
    outputBinding:
      glob: $(inputs.final_folder)/$(inputs.outname)_antismash_final.embl.gz

  reformated_clusters:
    type: File?
    outputBinding:
      glob: $(inputs.final_folder)/$(inputs.outname)_antismash_geneclusters.txt

  gff_antismash:
    type: File?
    outputBinding:
      glob: $(inputs.final_folder)/$(inputs.outname).antismash.gff.gz
  gff_antismash_index:
    type: File?
    outputBinding:
      glob: $(inputs.final_folder)/$(inputs.outname).antismash.gff.gz.tbi

  no_antismash:
    type: File?
    outputBinding:
      glob: $(inputs.final_folder)/no_antismash