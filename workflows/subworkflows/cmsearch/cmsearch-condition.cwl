cwlVersion: v1.2
class: Workflow
doc: |
  Identifies non-coding RNAs using Rfams covariance models

requirements:
  MultipleInputFeatureRequirement: {}

inputs:
  type: string
  query_sequences: File
  clan_info: [string, File]
  covariance_models:
    type:
      - type: array
        items: [string, File]

outputs:

  concatenate_matches:
    outputSource:
      - cmsearch_assembly/concatenate_matches
      - cmsearch_raw_data/concatenate_matches
    pickValue: first_non_null
    type: File
  deoverlapped_matches:
    outputSource:
      - cmsearch_assembly/deoverlapped_matches
      - cmsearch_raw_data/deoverlapped_matches
    pickValue: first_non_null
    type: File

steps:
  cmsearch_assembly:
    when: $(inputs.type == 'assembly')
    label: Search sequence(s) against a covariance model database for assemblies
    run: cmsearch-multimodel-assembly.cwl
    in:
      type: type
      clan_info: clan_info
      covariance_models: covariance_models
      query_sequences: query_sequences
    out: [ concatenate_matches, deoverlapped_matches ]

  cmsearch_raw_data:
    when: $(inputs.type == 'raw')
    label: Search sequence(s) against a covariance model database for amplicon and wgs
    run: cmsearch-multimodel-raw-data.cwl
    in:
      type: type
      clan_info: clan_info
      covariance_models: covariance_models
      query_sequences: query_sequences
    out: [ concatenate_matches, deoverlapped_matches ]

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'

$schemas:
  - 'http://edamontology.org/EDAM_1.16.owl'
  - 'https://schema.org/version/latest/schemaorg-current-http.rdf'

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2018"
s:author: "Ekaterina Sakharova"