#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "antiSMASH"
doc: |
  antiSMASH allows the rapid genome-wide identification, annotation and analysis
  of secondary metabolite biosynthesis gene clusters in bacterial and fungal genomes.
  It integrates and cross-links with a large number of in silico secondary metabolite analysis tools


requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    coresMax: 4
    ramMin: 40000

hints:
  DockerRequirement:
    dockerPull: mgnify/pipeline-v5.antismash

inputs:

  outdirname:
    type: string
    inputBinding:
      prefix: -o

  input_fasta:
    format: edam:format_1929  # FASTA
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

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/version/latest/schema.rdf

's:author': 'Ekaterina Sakharova'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"