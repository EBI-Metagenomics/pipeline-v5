class: Workflow
cwlVersion: v1.0

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
$schemas:
  - 'http://edamontology.org/EDAM_1.20.owl'
  - 'https://schema.org/docs/schema_org_rdfa.html'

requirements:
  - class: ResourceRequirement
    ramMin: 5000
    ramMax: 10000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  proteins: File

  InterProScan_applications: string[]?  #../tools/InterProScan/InterProScan-apps.yaml#apps[]?
  InterProScan_outputFormat: string[]?  # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?
  InterProScan_databases: Directory



outputs: []

steps:

  split_seqs:
    run: ../tools/chunks/fasta_chunker_old.cwl
    in:
      seqs: proteins
      chunk_size: { default: 100000 }
    out: [ chunks ]

  # << Functional annotation. InterProScan >>
  interproscan:
    scatter: inputFile
    in:
      inputFile: split_seqs/chunks
      applications: InterProScan_applications
      outputFormat: InterProScan_outputFormat
      databases: InterProScan_databases
    out:
      - i5Annotations
    run: ../tools/InterProScan/InterProScan-v5-none_docker.cwl
    label: "InterProScan: protein sequence classifier"

  # interpro
  combine_interpro:
    run: ../tools/chunks/concatenate.cwl
    in:
      files: interproscan/i5Annotations
      outputFileName: { default: "interpro" }
    out: [ result ]
    label: "combine all chunked interpro outputs to 1 tsv"