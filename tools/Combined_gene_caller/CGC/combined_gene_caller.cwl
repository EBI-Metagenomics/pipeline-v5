#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Combined Gene Caller"

hints:
  - class: DockerRequirement
    dockerPull: gene_caller:latest

requirements:
  ResourceRequirement:
    ramMin: 2000
    coresMin: 4

baseCommand: [combined_gene_caller.py]

arguments: ["-v"]

inputs:
  input_fasta:
    format: 'edam:format_1929'
    type: File
    inputBinding:
      separate: true
      prefix: "-i"

  seq_type:
    type: string
    inputBinding:
      prefix: "-s"

  maskfile:
    type: File
    inputBinding:
        prefix: "-k"

  outdir:
    type: string
    inputBinding:
        prefix: "-o"

  config:
    type: File
    default:
      class: File
      location: combined_gene_caller_conf.json
      basename: combined_gene_caller_conf
    inputBinding:
      prefix: "-c"

stdout: stdout.txt
stderr: stderr.txt


outputs:
  stdout: stdout
  stderr: stderr

  predicted_proteins:
    format: 'edam:format_1929'
    type: File
    outputBinding:
      glob: "CGC-output/$(inputs.input_fasta.basename).faa"
  predicted_seq:
    format: 'edam:format_1929'
    type: File
    outputBinding:
      glob: "CGC-output/$(inputs.input_fasta.basename).ffn"
#  gene_caller_out:
#    type: File
#    outputBinding:
#      glob: "$(inputs.input_fasta.basename).out"


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: "Ekaterina Sakharova"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"