#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/motus:2.1.1--py37_3


label: "mOTU taxonomy assignment for assemblies"

inputs:
  forward_reads:
    type: File
    inputBinding:
        position: 1
        prefix: -f
    label: raw forward reads post qc
    format: edam:format_1930

  reverse_reads:
    type: File
    inputBinding:
        position: 2
        prefix: -r
    label: raw reverse reads post qc
    format: edam:format_1930

  unpaired_reads:
    type: File
    inputBinding:
        position: 3
        prefix: -s
    label: unpaired reads post qc
    format: edam:format_1930

  match_length:
    type: int
    inputBinding:
        prefix: -l
    label: minimum match length for classification

baseCommand: [motus]

arguments: [profile, -c, -q, -B]

stdout: classifications.motus.biom

outputs:
  motu_taxonomy:
    type: stdout
    label: motu classifications
    format: edam:format_3746

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.18.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:author': 'Varsha Kale'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"
