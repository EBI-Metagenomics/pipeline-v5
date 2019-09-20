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
    ramMin: 50000
    coresMin: 32
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  proteins: File

  HMMSCAN_gathering_bit_score: boolean
  HMMSCAN_omit_alignment: boolean
  HMMSCAN_name_database: string
  HMMSCAN_data: Directory

  EggNOG_db: File
  EggNOG_diamond_db: File
  EggNOG_data_dir: string


outputs:
  #hmmscan_files:
  #  type: File[]
  #  outputSource: hmmscan/output_table

  eggnog_annotations:
    type: File[]
    outputSource: eggnog/output_annotations
  eggnog_orthologs:
    type: File[]
    outputSource: eggnog/output_orthologs

steps:

  split_seqs:
    run: ../tools/chunks/fasta_chunker.cwl
    in:
      seqs: proteins
      chunk_size: { default: 1000 }
    out: [ chunks ]

# << Functional annotation. eggnog >>
  eggnog:
    scatter: fasta_file
    run: ../tools/EggNOG/eggNOG/eggnog.cwl
    in:
      fasta_file: split_seqs/chunks
      db: EggNOG_db
      db_diamond: EggNOG_diamond_db
      data_dir: EggNOG_data_dir
    out: [output_annotations, output_orthologs]

# << Functional annotation. hmmscan >>
  #hmmscan:
  #  scatter: seqfile
  #  in:
  #    seqfile: split_seqs/chunks
  #    gathering_bit_score: HMMSCAN_gathering_bit_score
  #    name_database: HMMSCAN_name_database
  #    data: HMMSCAN_data
  #    omit_alignment: HMMSCAN_omit_alignment
  #  out:
  #    - output_table
  #  run: ../tools/hmmscan/hmmscan.cwl
