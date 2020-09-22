#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  input_table_hmmscan: File
  filtered_fasta: File
  outputname: string
  graphs: [string, File]
  pathways_names: [string, File]
  pathways_classes: [string, File]

outputs:

  modification_out:
    outputSource: tab_modification/output_with_tabs
    type: File
  parsing_hmmscan_out:
    outputSource: parsing_hmmscan/output_table
    type: File
  kegg_pathways_summary:
    outputSource: kegg_pathways/summary_pathways
    type: File
  kegg_contigs_summary:
    outputSource: kegg_pathways/summary_contigs
    type: File

steps:

  tab_modification:
    in:
      input_table: input_table_hmmscan
    out: [ output_with_tabs ]
    run: ../../../tools/Assembly/KEGG_analysis/Modification/modification_table.cwl
    label: "make table tab-separated"

  parsing_hmmscan:
    in:
      table: tab_modification/output_with_tabs
      fasta: filtered_fasta
    out: [ output_table ]
    run: ../../../tools/Assembly/KEGG_analysis/Parsing_hmmscan/parsing_hmmscan.cwl
    label: "leave file with contig and it's KO"

  kegg_pathways:
    in:
      input_table: parsing_hmmscan/output_table
      graphs: graphs
      pathways_names: pathways_names
      pathways_classes: pathways_classes
      outputname: outputname
    out:
      - summary_pathways
      - summary_contigs
    run: ../../../tools/Assembly/KEGG_analysis/KEGG_pathways/kegg_pathways.cwl


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"
