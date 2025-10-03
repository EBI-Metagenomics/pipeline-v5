cwlVersion: v1.0
class: Workflow
$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
label: Identifies non-coding RNAs using Rfams covariance models

requirements:
  ScatterFeatureRequirement: {}
  ResourceRequirement:
    ramMin: 5000
    coresMin: 4

inputs:
  query_sequences: File
  covariance_models: string[]
  clan_info: string

outputs:
  concatenate_matches:
    outputSource: run_concatenate_matches/result
    type: File
  deoverlapped_matches:
    outputSource: run_concatenate_deoverlapped_matches/result
    type: File

steps:

  cat_models:
    run: ../../utils/concatenate.cwl
    in:
      files: covariance_models
      outputFileName: {default: 'models_cmsearch'}
      postfix: {default: '.all.tblout'}
    out: [ result ]

  split_fasta:
    run: ../../tools/chunks/dna_chunker/fasta_chunker.cwl
    in:
      seqs: query_sequences
      chunk_size: { default: 2000000 }
      number_of_output_files: { default: "False" }
      same_number_of_residues: { default: "False" }
    out: [ chunks ]

  cmsearch:
    label: Search sequence(s) against a covariance model database
    run: ../../tools/RNA_prediction/cmsearch/infernal-cmsearch-v1.1.2.cwl
    scatter: query_sequences
    in:
      query_sequences: split_fasta/chunks
      covariance_model_database: cat_models/result
      cpu: { default: 8 }
      omit_alignment_section: { default: true }
      only_hmm: { default: true }
      search_space_size: { default: 1000 }
      cut_ga: { default: true }
    out: [ matches ]

  run_concatenate_matches:
    run: ../../utils/concatenate.cwl
    in:
      files: cmsearch/matches
      outputFileName:
        source: query_sequences
        valueFrom: $(self.nameroot)
      postfix: { default: ".cmsearch.all.tblout" }
    out: [ result ]

  remove_overlaps:
    label: Remove lower scoring overlaps from cmsearch --tblout files.
    run: ../../tools/RNA_prediction/cmsearch-deoverlap/cmsearch-deoverlap-v0.02.cwl
    in:
      clan_information: clan_info
      cmsearch_matches: cmsearch/matches
    scatter: cmsearch_matches
    out: [ deoverlapped_matches ]

  run_concatenate_deoverlapped_matches:
    run: ../../utils/concatenate.cwl
    in:
      files: remove_overlaps/deoverlapped_matches
      outputFileName:
        source: query_sequences
        valueFrom: $(self.nameroot)
      postfix: { default: ".cmsearch.all.tblout.deoverlapped" }
    out: [ result ]

$schemas:
  - 'http://edamontology.org/EDAM_1.16.owl'
  - 'https://schema.org/version/latest/schemaorg-current-http.rdf'
s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute, 2020"
s:author: "Ekaterina Sakharova, Martin Beracochea"