cwlVersion: v1.0
class: Workflow
$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
label: Identifies non-coding RNAs using Rfams covariance models

requirements:
  - class: ScatterFeatureRequirement

inputs:
  clan_info: [string, File]
  #cores: int
  covariance_models:
    type:
      - type: array
        items: [string, File]
  query_sequences: File
  targetFile: File

outputs:
  cmsearch_matches:
    outputSource: cmsearch/matches
    type: File[]
  concatenate_matches:
    outputSource: run_concatenate_matches/result
    type: File
  deoverlapped_matches:
    outputSource: remove_overlaps/deoverlapped_matches
    type: File

steps:
  cmsearch:
    label: Search sequence(s) against a covariance model database
    run: ../../tools/RNA_prediction/cmsearch/infernal-cmsearch-v1.1.2.cwl
    in:
      covariance_model_database: covariance_models
      cpu: { default: 8 }
      omit_alignment_section:
        default: true
      only_hmm:
        default: true
      query_sequences: query_sequences
      search_space_size:
        default: 1000
    scatter: covariance_model_database
    out: [ matches, programOutput ]

  run_concatenate_matches:
    run: ../../utils/concatenate.cwl
    in:
      files:
        - cmsearch/matches
      outputFileName:
        source: targetFile
        valueFrom: $(self.nameroot)
      postfix: { default: ".cmsearch.all.tblout" }
    out: [ result ]

  remove_overlaps:
    label: Remove lower scoring overlaps from cmsearch --tblout files.
    run: ../../tools/RNA_prediction/cmsearch-deoverlap/cmsearch-deoverlap-v0.02.cwl
    in:
      clan_information: clan_info
      cmsearch_matches: run_concatenate_matches/result
    out: [ deoverlapped_matches ]
$schemas:
  - 'http://edamontology.org/EDAM_1.16.owl'
  - 'https://schema.org/version/latest/schemaorg-current-http.rdf'
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2018"
s:author: "Arnaud Meng, Maxim Scheremetjew, Ekaterina Sakharova"