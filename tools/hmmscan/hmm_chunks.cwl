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
    ramMin: 10000
    coresMin: 32
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  input_file: File
  gathering_bit_score: boolean
  name_database: string
  data: Directory
  omit_alignment: boolean

outputs:
  hmmscan_result:
    type: File
    outputSource: combine_hmm/result

steps:

  split_seqs:
    run: ../tools/chunks/fasta_chunker.cwl
    in:
      seqs: input_file
      chunk_size: { default: 10 }
    out: [ chunks ]

# << Functional annotation. hmmscan >>
  hmmscan:
    scatter: seqfile
    run: ../tools/hmmscan/hmmscan-subwf.cwl
    in:
      seqfile: split_seqs/chunks
      gathering_bit_score: gathering_bit_score
      name_database: name_database
      data: data
      omit_alignment: omit_alignment
    out: [output_table]

# << Unite hmmscan >>
  combine_hmm:
    run: ../../utils/concatenate.cwl
    in:
      files: hmmscan/output_table
    out: [ result ]
    label: "combined chunked hmmscam outputs"

# << Add header >>