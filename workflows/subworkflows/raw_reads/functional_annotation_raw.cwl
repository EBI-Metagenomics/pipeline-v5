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
  chunk_size: int
  name_ips: string
  name_hmmscan: string

  HMMSCAN_gathering_bit_score: boolean
  HMMSCAN_omit_alignment: boolean
  HMMSCAN_name_database: string
  HMMSCAN_data: Directory

  InterProScan_databases: Directory
  InterProScan_applications: string[]  # ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
  InterProScan_outputFormat: string[]  # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?

outputs:
  hmmscan_result:
    type: File
    outputSource: run_hmmscan/hmmscan_result
  ips_result:
    type: File
    outputSource: run_IPS/ips_result

steps:

  run_IPS:
    run: ../chunking-subwf-IPS.cwl
    in:
      CGC_predicted_proteins: CGC_predicted_proteins
      chunk_size: chunk_size
      name_ips: name_ips
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
    out: [ ips_result ]

  run_hmmscan:
    run: ../chunking-subwf-hmmscan.cwl
    in:
      CGC_predicted_proteins: CGC_predicted_proteins
      chunk_size: chunk_size
      name_hmmscan: name_hmmscan
      HMMSCAN_gathering_bit_score: HMMSCAN_gathering_bit_score
      HMMSCAN_omit_alignment: HMMSCAN_omit_alignment
      HMMSCAN_name_database: HMMSCAN_name_database
      HMMSCAN_data: HMMSCAN_data
      previous_step_result: run_IPS/ips_result
    out: [ hmmscan_result ]
