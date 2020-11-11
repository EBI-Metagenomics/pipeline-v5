#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Combined Gene Caller: Prodigal"

hints:
  - class: DockerRequirement
    dockerPull: microbiomeinformatics/pipeline-v5.prodigal:v2.6.3

requirements:
  ResourceRequirement:
    ramMin: 5000
    coresMin: 4

baseCommand: [ prodigal ]

arguments:
  - valueFrom: "sco"
    prefix: "-f"
  - valueFrom: "meta"
    prefix: "-p"
  - valueFrom: $(inputs.input_fasta.basename).prodigal
    prefix: "-o"
  - valueFrom: $(inputs.input_fasta.basename).prodigal.ffn
    prefix: "-d"
  - valueFrom: $(inputs.input_fasta.basename).prodigal.faa
    prefix: "-a"

inputs:
  input_fasta:
    format: 'edam:format_1929'
    type: File
    inputBinding:
      separate: true
      prefix: "-i"

stdout: stdout.txt
stderr: stderr.txt

outputs:
  stdout: stdout
  stderr: stderr

  predicted_proteins_out:
    type: File
    outputBinding:
      glob: $(inputs.input_fasta.basename).prodigal
  predicted_proteins_ffn:
    type: File
    outputBinding:
      glob: $(inputs.input_fasta.basename).prodigal.ffn
  predicted_proteins_faa:
    type: File
    outputBinding:
      glob: $(inputs.input_fasta.basename).prodigal.faa


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