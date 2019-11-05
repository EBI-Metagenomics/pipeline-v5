#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: CommandLineTool

requirements:
    ResourceRequirement:
        coresMin: 4
        ramMin: 10000

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/motus:2.1.1--py37_3
  SoftwareRequirement:
    packages:
      mOTUs2:
        specs: ["http://biom-format.org/index.html"]
        version: ["2.5.1"]


label: "mOTU taxonomy assignment for assemblies"

inputs:
  reads:
    type: File
    inputBinding:
        position: 1
        prefix: -s
    label: merged and QC reads in fastq
    #format: edam:format_1930

  threads:
    type: int
    inputBinding:
        prefix: -t
    default: 4

baseCommand: [motus]

arguments: [profile, -c, -q]
# -B]

stdout: $(inputs.reads.nameroot).motus_biom

outputs:
  motu_taxonomy:
    type: stdout
    label: motu classifications
    #format: edam:format_3746

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.18.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:author': 'Varsha Kale'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"