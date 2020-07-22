#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: visualize using krona


#edited from ebi-metagenomics-cwl/tools/krona.cwl

requirements:
  ResourceRequirement:
    ramMin: 200
    coresMin: 2

inputs:
  otu_counts:
    type: File
    label: Tab-delimited text file
    inputBinding:
      position: 2

baseCommand: ktImportText

arguments:
  - valueFrom: "krona.html"
    prefix: -o

outputs:
  otu_visualization:
    type: File
    format: iana:text/html
    outputBinding:
      glob: "*.html"

hints:
  DockerRequirement:
    dockerPull: kronav2.7.1:1.0

$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"