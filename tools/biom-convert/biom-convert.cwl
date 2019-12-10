#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  InlineJavascriptRequirement: {}
  ResourceRequirement:
    ramMin: 4000
#  SchemaDefRequirement:
#    types:
#      - $import: biom-convert-table.yaml

hints:
  DockerRequirement:
    dockerPull: quay.io/biocontainers/biom-format:2.1.6--py36_0
#  SoftwareRequirement:
#    packages:
#      biom-format:
#        specs: [ "https://doi.org/10.1186/2047-217X-1-7" ]
#        version: [ "2.1.6" ]
#


inputs:
  biom:
    type: File
    inputBinding:
      prefix: --input-fp

  table_type:
    type: string? #biom-convert-table.yaml#table_type?
    inputBinding:
      prefix: --table-type  # --table-type=    <- worked for cwlexec
      separate: true # false                                  <- worked for cwlexec
      valueFrom: $(inputs.table_type)  # $('"' + inputs.table_type + '"')      <- worked for cwlexec

  json:
    type: boolean?
    label: Output as JSON-formatted table.
    inputBinding:
      prefix: --to-json

  hdf5:
    type: boolean?
    label: Output as HDF5-formatted table.
    inputBinding:
      prefix: --to-hdf5

  tsv:
    type: boolean?
    label: Output as TSV-formatted (classic) table.
    inputBinding:
      prefix: --to-tsv

  header_key:
    type: string?
    doc: |
      The observation metadata to include from the input BIOM table file when
      creating a tsv table file. By default no observation metadata will be
      included.
    inputBinding:
      prefix: --header-key

baseCommand: [ "biom", "convert" ]

arguments:
  - valueFrom: |
     ${ var ext = "";
        if (inputs.json) { ext = "_json.biom"; }
        if (inputs.hdf5) { ext = "_hdf5.biom"; }
        if (inputs.tsv) { ext = "_tsv.biom"; }
        return inputs.biom.nameroot + ext; }
    prefix: --output-fp
  - valueFrom: "--collapsed-observations"


outputs:
  result:
    type: File
    outputBinding:
      glob: |
       ${ var ext = "";
       if (inputs.json) { ext = "_json.biom"; }
       if (inputs.hdf5) { ext = "_hdf5.biom"; }
       if (inputs.tsv) { ext = "_tsv.biom"; }
       return inputs.biom.nameroot + ext; }

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"