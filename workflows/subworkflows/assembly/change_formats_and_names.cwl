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
  genome_properties_summary: File
  kegg_summary: File
  fasta: File

outputs:
  gp_summary_csv:
    type: File
    outputSource: create_csv_gp/csv_result
  kegg_summary_csv:
    type: File
    outputSource: create_csv_kp/csv_result

steps:

# change TSV to CSV for genome_properties
  create_csv_gp:
    run: ../../../utils/make_csv/make_csv.cwl
    in:
      tab_sep_table: genome_properties_summary
      output_name:
        source: genome_properties_summary
        valueFrom: $(self.nameroot.split('SUMMARY_FILE_')[1])
    out: [csv_result]

# change TSV to CSV for kegg_pathways
  create_csv_kp:
    run: ../../../utils/make_csv/make_csv.cwl
    in:
      tab_sep_table: kegg_summary
      output_name:
        source: kegg_summary
        valueFrom: $(self.nameroot)
    out: [csv_result]



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
