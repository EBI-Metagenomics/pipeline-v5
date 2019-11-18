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
    ramMin: 40000
    coresMin: 32
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  inputFile: File
  applications: string[]
  outputFormat: string[]
  databases: Directory

outputs:
  interpro_result:
    type: File
    outputSource: combine/result

steps:

  split_seqs:
    run: ../chunks/fasta_chunker.cwl
    in:
      seqs: inputFile
      chunk_size: { default: 10000 }
    out: [ chunks ]

# << Functional annotation. InterProScan >>
  interpo:
    scatter: inputFile
    run: InterProScan-v5-none_docker.cwl
    in:
      inputFile: split_seqs/chunks
      applications: applications
      outputFormat: outputFormat
      databases: databases
    out: [ i5Annotations ]

# << Unite  >>
  combine:
    run: ../chunks/concatenate.cwl
    in:
      files: interpo/i5Annotations
      outputFileName: { default: 'interpo_united' }
    out: [ result ]

# << Add header >> ???
# written but not tested