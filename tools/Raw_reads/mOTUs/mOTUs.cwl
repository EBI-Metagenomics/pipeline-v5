#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
    ResourceRequirement:
        coresMin: 4
        ramMin: 300

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.motus:v2.5.1
  SoftwareRequirement:
    packages:
      mOTUs2:
        specs: ["http://biom-format.org/index.html"]
        version: ["2.5.1"]

label: "mOTU taxonomy assignment for assemblies"

baseCommand: [ motus ]

inputs:
  reads:
    type: File
    inputBinding:
      position: 1
      prefix: -s
    label: merged and QC reads in fastq
    # format: edam:format_1930  # FASTQ

  threads:
    type: int
    inputBinding:
      prefix: -t
    default: 4

  db:
    type: string
    inputBinding:
      prefix: -db
    # FIXME: hardcoded test value
    default: /data/databases/pipeline-v5/motus-v2.5.1/


arguments: [profile, -c, -q]

stdout: $(inputs.reads.nameroot).motus
stderr: stderr.txt

outputs:
  motu_taxonomy:
    type: stdout
    label: motu classifications
    format: edam:format_3746
  stderr: stderr

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.18.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:author: 'Varsha Kale'
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
