#!/usr/bin/env cwl-runner
class: Workflow
cwlVersion: v1.0

requirements:
  ResourceRequirement:
      ramMin: 1000
      coresMin: 1
  SubworkflowFeatureRequirement: {}
  ScatterFeatureRequirement: {}
  InlineJavascriptRequirement: {}

inputs:

  CGC_predicted_proteins: File
  chunk_size: int
  name_ips: string

  InterProScan_databases: [string, Directory]
  InterProScan_applications: string[]
  InterProScan_outputFormat: string[]

outputs:
  ips_result:
    type: File
    outputSource: combine_ips/result

steps:
  # << Chunk faa file >>
  split_seqs:
    in:
      seqs: CGC_predicted_proteins
      chunk_size: chunk_size
    out: [ chunks ]
    run: ../../tools/chunks/protein_chunker.cwl

  # << InterProScan >>
  interproscan:
    scatter: inputFile
    in:
      applications: InterProScan_applications
      inputFile: split_seqs/chunks
      outputFormat: InterProScan_outputFormat
      databases: InterProScan_databases
    out: [ i5Annotations ]
    run: ../../tools/InterProScan/InterProScan-v5.cwl
    label: "InterProScan: protein sequence classifier"

  combine_ips:
    in:
      files: interproscan/i5Annotations
      outputFileName:
        source: CGC_predicted_proteins
        valueFrom: $(self.nameroot.split('_CDS')[0])
      postfix: name_ips
    out: [result]
    run: ../../utils/concatenate.cwl


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
