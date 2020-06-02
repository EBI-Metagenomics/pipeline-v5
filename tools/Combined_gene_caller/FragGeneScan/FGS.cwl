#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Combined Gene Caller: FragGeneScan"

hints:
  - class: DockerRequirement
    dockerPull: mgnify/pipeline-v5.fraggenescan:latest

requirements:
  ResourceRequirement:
    ramMin: 5000
    coresMin: 4

baseCommand: [ run_FGS.sh ]

arguments:

inputs:
  input_fasta:
    format: 'edam:format_1929'
    type: File
    inputBinding:
      separate: true
      prefix: "-i"
  output:
    type: string
    inputBinding:
      separate: true
      prefix: "-o"
  seq_type:
    type: string
    inputBinding:
      separate: true
      prefix: "-s"

stdout: stdout.txt
stderr: stderr.txt

outputs:
  stdout: stdout
  stderr: stderr

  predicted_proteins_out:
    type: File
    outputBinding:
      glob: $(inputs.output).out
  predicted_proteins_ffn:
    type: File
    outputBinding:
      glob: $(inputs.output).ffn
  predicted_proteins_faa:
    type: File
    outputBinding:
      glob: $(inputs.output).faa


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

's:author': 'Ekaterina Sakharova'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"