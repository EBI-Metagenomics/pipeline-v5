#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    ramMin: 200
    tmpdirMin: 200
    coresMin: 2

hints:
  DockerRequirement:
    dockerPull: microbiomeinformatics/pipeline-v5.mapseq2biom:v1.0

baseCommand: [ 'mapseq2biom.pl' ]

inputs:
  otu_table:
    type: [string, File]
    doc: |
      the OTU table produced for the taxonomies found in the reference
      databases that was used with MAPseq
    inputBinding:
      prefix: --otuTable 

  query:
    type: File
    label: the output from the MAPseq that assigns a taxonomy to a sequence
    format: iana:text/tab-separated-values
    inputBinding:
      prefix: --query

  label:
    type: string
    label: label to add to the top of the outfile OTU table
    inputBinding:
      prefix: --label

  taxid_flag:
    type: boolean?
    label: output NCBI taxids for all databases bar UNITE
    inputBinding:
        prefix: --taxid

arguments:
  - valueFrom: $(inputs.query.basename).tsv
    prefix: --outfile
  - valueFrom: $(inputs.query.basename).txt
    prefix: --krona
  - valueFrom: $(inputs.query.basename).notaxid.tsv
    prefix: --notaxidfile

stderr: stderr.txt

outputs:
  stderr:
    type: stderr
  otu_tsv:
    type: File
    format: edam:format_3746  # BIOM
    outputBinding:
      glob: $(inputs.query.basename).tsv

  otu_txt:
    type: File
    format: iana:text/tab-separated-values
    outputBinding:
      glob: $(inputs.query.basename).txt

  otu_tsv_notaxid:
    type: File?
    format: edam:format_3746  # BIOM
    outputBinding:
      glob: $(inputs.query.basename).notaxid.tsv

$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/

$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"
