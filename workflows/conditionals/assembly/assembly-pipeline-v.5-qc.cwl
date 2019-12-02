class: Workflow
cwlVersion: v1.0

$namespaces:
  edam: 'http://edamontology.org/'
  s: 'http://schema.org/'
$schemas:
  - 'http://edamontology.org/EDAM_1.20.owl'
  - 'https://schema.org/docs/schema_org_rdfa.html'

requirements:
#  - class: SchemaDefRequirement
#    types:
#      - $import: ../tools/Diamond/Diamond-strand_values.yaml
#      - $import: ../tools/Diamond/Diamond-output_formats.yaml
#      - $import: ../tools/InterProScan/InterProScan-apps.yaml
#      - $import: ../tools/InterProScan/InterProScan-protein_formats.yaml
  - class: ResourceRequirement
    ramMin: 50000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:

    contigs: File
    contig_min_length: int

 # << rna prediction >>
    ssu_db: {type: File, secondaryFiles: [.mscluster] }
    lsu_db: {type: File, secondaryFiles: [.mscluster] }
    ssu_tax: File
    lsu_tax: File
    ssu_otus: File
    lsu_otus: File

    rfam_models: File[]
    rfam_model_clans: File
    other_ncrna_models: string[]

    ssu_label: string
    lsu_label: string
    5s_pattern: string
    5.8s_pattern: string

 # << cgc >>
    CGC_config: File
    CGC_postfixes: string[]
    cgc_chunk_size: int

 # << functional annotation >>
    fa_chunk_size: int
    func_ann_names_ips: string
    func_ann_names_hmmscan: string
    HMMSCAN_gathering_bit_score: boolean
    HMMSCAN_omit_alignment: boolean
    HMMSCAN_name_database: string
    HMMSCAN_data: Directory
    hmmscan_header: string
    EggNOG_db: File
    EggNOG_diamond_db: File
    EggNOG_data_dir: string
    InterProScan_databases: Directory
    InterProScan_applications: string[]  # ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
    InterProScan_outputFormat: string[]  # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?
    ips_header: string

 # << diamond >>
    Uniref90_db_txt: File
    diamond_maxTargetSeqs: int
    diamond_databaseFile: File
    diamond_header: string

 # << GO >>
    go_config: File

 # << Pathways >>
    graphs: File
    pathways_names: File
    pathways_classes: File

 # << genome properties >>
    gp_flatfiles_path: string

 # << antismash summary >>
    clusters_glossary: File

outputs:

 # << root folder >>
  compressed_files:                                          # [5] fasta, cmsearch, ncRNA, deoverlapped
    type: File[]
    outputSource: after-qc/compressed_file
  index_fasta_file:                                          # [1] fasta.bgz.fai
    type: File
    outputSource: after-qc/fasta_index
  bgzip_fasta_file:                                          # [1] fasta.bgz
    type: File
    outputSource: after-qc/fasta_bgz
  chunking_nucleotides:                                      # [2] fasta, ffn
    type: File[]
    outputSource: after-qc/nucleotide_fasta_chunks
  chunking_proteins:                                         # [1] faa
    type: File[]
    outputSource: after-qc/protein_fasta_chunks
  qc-status:                                                 # [1]
    type: File
    outputSource: before-qc/qc-status
  qc_summary:                                                # [1]
    type: File
    outputSource: before-qc/qc_summary

 # << qc-statistics >>
  qc-statistics_folder:                                      # [8]
    type: Directory
    outputSource: before-qc/qc-statistics_folder

 # << functional annotation >>
  functional_annotation_folder:                              # [15]
    type: Directory
    outputSource: after-qc/functional_annotation_folder
  stats:                                                     # [6]
    outputSource: after-qc/stats
    type: Directory

 # << pathways and systems >>
  pathways_systems_folder:                                   # [~10]
    type: Directory
    outputSource: after-qc/out

 # << sequence categorisation >>
  sequence-categorisation_folder:                            # [6]
    type: Directory
    outputSource: after-qc/sequence-categorisation
#  sequence-categorisation_SSU_LSU:                           # [2]
#    type: Directory
#    outputSource: after-qc/sequence-categorisation_two
  sequence-categorisation_SSU_LSU_chunked:                   # [2]
    type: Directory
    outputSource: after-qc/out
  other_rna:                                                 # [?]
    type: Directory
    outputSource: after-qc/ncrnas

 # << taxonomy summary >>
  LSU_folder:                                                # [6]
    type: Directory
    outputSource: after-qc/LSU_folder
  SSU_folder:                                                # [6]
    type: Directory
    outputSource: after-qc/SSU_folder

steps:

  before-qc:
    in:
      contigs: contigs
      contig_min_length: contig_min_length
    out:
      - qc-status
      - qc_summary
      - qc-statistics_folder
      - filtered_fasta
    run: assembly-1.cwl


  after-qc:
    in:
      filtered_fasta: before-qc/filtered_fasta
      ssu_db: ssu_db
      lsu_db: lsu_db
      ssu_tax: ssu_tax
      lsu_tax: lsu_tax
      ssu_otus: ssu_otus
      lsu_otus: lsu_otus
      rfam_models: rfam_models
      rfam_model_clans: rfam_model_clans
      other_ncrna_models: other_ncrna_models
      ssu_label: ssu_label
      lsu_label: lsu_label
      5s_pattern: 5s_pattern
      5.8s_pattern: 5.8s_pattern
      CGC_config: CGC_config
      CGC_postfixes: CGC_postfixes
      cgc_chunk_size: cgc_chunk_size
      fa_chunk_size: fa_chunk_size
      func_ann_names_ips: func_ann_names_ips
      func_ann_names_hmmscan: func_ann_names_hmmscan
      HMMSCAN_gathering_bit_score: HMMSCAN_gathering_bit_score
      HMMSCAN_omit_alignment: HMMSCAN_omit_alignment
      HMMSCAN_name_database: HMMSCAN_name_database
      HMMSCAN_data: HMMSCAN_data
      hmmscan_header: hmmscan_header
      EggNOG_db: EggNOG_db
      EggNOG_diamond_db: EggNOG_diamond_db
      EggNOG_data_dir: EggNOG_data_dir
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
      ips_header: ips_header
      Uniref90_db_txt: Uniref90_db_txt
      diamond_maxTargetSeqs: diamond_maxTargetSeqs
      diamond_databaseFile: diamond_databaseFile
      diamond_header: diamond_header
      go_config: go_config
      graphs: graphs
      pathways_names: pathways_names
      pathways_classes: pathways_classes
      gp_flatfiles_path: gp_flatfiles_path
      clusters_glossary: clusters_glossary
    out:
      - compressed_files
      - index_fasta_file
      - bgzip_fasta_file
      - chunking_nucleotides
      - chunking_proteins
      - functional_annotation_folder
      - stats
      - pathways_systems_folder
      - sequence-categorisation_folder
      - sequence-categorisation_SSU_LSU_chunked
      - other_rna
      - LSU_folder
      - SSU_folder
    run: assembly-2.cwl