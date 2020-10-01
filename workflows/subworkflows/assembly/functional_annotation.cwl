#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  ResourceRequirement:
      ramMin: 1000
      coresMin: 1
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
#  - class: SchemaDefRequirement
#    types:
#      - $import: ../tools/InterProScan/InterProScan-apps.yaml
#      - $import: ../tools/InterProScan/InterProScan-protein_formats.yaml

inputs:

  CGC_predicted_proteins: File

  name_hmmer: string
  chunk_size_hmm: int
  HMM_gathering_bit_score: boolean
  HMM_omit_alignment: boolean
  HMM_database: string

  chunk_size_eggnog: int
  EggNOG_db: [string, File]
  EggNOG_diamond_db: [string, File]
  EggNOG_data_dir: [string, Directory]

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
  eggnog_annotations:
    outputSource: eggnog/annotations
    type: File
  eggnog_orthologs:
    outputSource: eggnog/orthologs
    type: File

steps:

  # << Chunk faa file >>
  split_seqs:
    in:
      seqs: CGC_predicted_proteins
      chunk_size: chunk_size_eggnog
    out: [ chunks ]
    run: ../../../tools/chunks/protein_chunker.cwl

  # << EggNOG >>
  eggnog:
    run: ../../../tools/Assembly/EggNOG/eggnog-subwf.cwl
    in:
      fasta_file: split_seqs/chunks
      db_diamond: EggNOG_diamond_db
      db: EggNOG_db
      data_dir: EggNOG_data_dir
      cpu: { default: 16 }
      file_acc:
        source: CGC_predicted_proteins
        valueFrom: $(self.nameroot)
    out: [ annotations, orthologs ]

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
