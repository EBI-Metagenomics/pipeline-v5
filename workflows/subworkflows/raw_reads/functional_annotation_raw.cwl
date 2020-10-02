#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  ResourceRequirement:
      ramMin: 1000
      coresMin: 1
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}

inputs:

  CGC_predicted_proteins: File

  name_hmmer: string
  chunk_size_hmm: int
  HMM_gathering_bit_score: boolean
  HMM_omit_alignment: boolean
  HMM_database: string
  HMM_database_dir: Directory?

  chunk_size_IPS: int
  name_ips: string
  InterProScan_databases: string
  InterProScan_applications: string[]  # ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
  InterProScan_outputFormat: string[]  # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?

outputs:
  hmm_result:
    type: File
    outputSource: run_hmmer/hmm_result
  ips_result:
    type: File
    outputSource: run_IPS/ips_result

steps:

  run_IPS:
    run: ../chunking-subwf-IPS.cwl
    in:
      CGC_predicted_proteins: CGC_predicted_proteins
      chunk_size: chunk_size_IPS
      name_ips: name_ips
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
    out: [ ips_result ]

  run_hmmer:
    run: ../chunking-subwf-hmmsearch.cwl
    in:
      CGC_predicted_proteins: CGC_predicted_proteins
      chunk_size: chunk_size_hmm
      name_hmmer: name_hmmer
      HMM_gathering_bit_score: HMM_gathering_bit_score
      HMM_omit_alignment: HMM_omit_alignment
      HMM_database: HMM_database
      HMM_database_dir: HMM_database_dir
      previous_step_result: run_IPS/ips_result
    out: [ hmm_result ]


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
