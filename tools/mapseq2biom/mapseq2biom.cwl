#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
#  DockerRequirement:
#    dockerPull: mapseq2biom:latest
  ResourceRequirement:
    ramMin: 10000
    ramMax: 10000
    tmpdirMin: 15000
    coresMin: 2

inputs:
  otu_table:
    type: File
    doc: |
      the OTU table produced for the taxonomies found in the reference
      databases that was used with MAPseq
    inputBinding:
      prefix: --otuTable 

  query:
    type: File
    label: the output from the MAPseq that assigns a taxonomy to a sequence
    inputBinding:
      prefix: --query

  label:
    type: string
    label: label to add to the top of the outfile OTU table
    inputBinding:
      prefix: --label

baseCommand: ['mapseq2biom.pl'] # or perl /hps/nobackup/production/metagenomics/production-scripts/current/mgportal/analysis-pipeline/python/tools/taxonomy_summary/scripts/mapseq2biom.pl

arguments:
  - valueFrom: $(inputs.query.basename).tsv
    prefix: --outfile
  - valueFrom: $(inputs.label).txt
    prefix: --krona

outputs:
  otu_tsv:
    type: File
    format: edam:format_3746
    outputBinding:
      glob: $(inputs.query.basename).tsv

  otu_txt:
    type: File
    format: edam:format_2330
    outputBinding:
      glob: $(inputs.label).txt

$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
