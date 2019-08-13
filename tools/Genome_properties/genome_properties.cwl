#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

label: "Genome properties https://genome-properties.readthedocs.io"

requirements:
  DockerRequirement:
    dockerPull: genome_properties:latest
  InlineJavascriptRequirement: {}

baseCommand: ["perl", "/genome-properties/code/scripts/assign_genome_properties.pl"]
arguments: ["-name", "$(inputs.input_tsv_file.nameroot)", "-all", "-gpdir", "/genome-properties/flatfiles", "-outfiles", "summary", "-gpff", "genomeProperties.txt"]

inputs:
  input_tsv_file:
    type: File
    inputBinding:
      separate: true
      prefix: "-matches"

  out_dir:
    type: string?
    inputBinding:
      prefix: "-outdir"

stdout: stdout.txt
stderr: stderr.txt


outputs:
  stdout: stdout
  stderr: stderr

  summary:
    type: File
    outputBinding:
      glob: "*$(inputs.input_tsv_file.nameroot)"


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.20.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:author': 'Ekaterina Sakharova'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"