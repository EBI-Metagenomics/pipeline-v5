class: Workflow
cwlVersion: v1.2.0-dev4

requirements:
#  - class: SchemaDefRequirement
#    types:
#      - $import: ../tools/Diamond/Diamond-strand_values.yaml
#      - $import: ../tools/Diamond/Diamond-output_formats.yaml
#      - $import: ../tools/InterProScan/InterProScan-apps.yaml
#      - $import: ../tools/InterProScan/InterProScan-protein_formats.yaml
  - class: ResourceRequirement
    ramMin: 20000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
    filtered_fasta: File

    mapping_directory_mgyc: string?
    private: boolean?
    include_protein_assign: boolean?
    mgyp_config: string?
    mgyp_release: string?

 # << rna prediction >>
    ssu_db: {type: File, secondaryFiles: [.mscluster] }
    lsu_db: {type: File, secondaryFiles: [.mscluster] }
    ssu_tax: string
    lsu_tax: string
    ssu_otus: string
    lsu_otus: string

    rfam_models: string[]
    rfam_model_clans: string
    other_ncrna_models: string[]

    ssu_label: string
    lsu_label: string
    5s_pattern: string
    5.8s_pattern: string

 # << cgc >>
    CGC_config: string
    CGC_postfixes: string[]
    cgc_chunk_size: int

 # << functional annotation >>
    protein_chunk_size_eggnog: int
    protein_chunk_size_hmm: int
    protein_chunk_size_IPS: int
    func_ann_names_ips: string
    func_ann_names_hmmer: string
    HMM_gathering_bit_score: boolean
    HMM_omit_alignment: boolean
    HMM_name_database: string
    hmmsearch_header: string
    EggNOG_db: string
    EggNOG_diamond_db: string
    EggNOG_data_dir: string
    InterProScan_databases: string
    InterProScan_applications: string[]  # ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
    InterProScan_outputFormat: string[]  # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?
    ips_header: string
    ko_file: string

 # << diamond >>
    Uniref90_db_txt: string
    diamond_maxTargetSeqs: int
    diamond_databaseFile: string
    diamond_header: string

 # << GO >>
    go_config: string

 # << Pathways >>
    graphs: string
    pathways_names: string
    pathways_classes: string

 # << genome properties >>
    gp_flatfiles_path: string

 # << antismash summary >>
    clusters_glossary: string

outputs:

 # << root folder >>
  compressed_files:                                          # [2] cmsearch, ncRNA
    type: File[]
    outputSource: compression/compressed_file
  index_fasta_file:                                          # [1] fasta.bgz.fai
    type: File
    outputSource: fasta_index/fasta_index
  bgzip_fasta_file:                                          # [1] fasta.bgz
    type: File
    outputSource: fasta_index/fasta_bgz
  bgzip_index:                                               # [1] fasta.bgz.gzi
    type: File
    outputSource: fasta_index/bgz_index
  chunking_nucleotides:                                      # [2] fasta, ffn
    type: File[]?
    outputSource: chunking_final/nucleotide_fasta_chunks
  chunking_proteins:                                         # [1] faa
    type: File[]?
    outputSource: chunking_final/protein_fasta_chunks

 # << functional annotation >>
  functional_annotation_folder:                              # [15]
    type: Directory?
    outputSource: functional_annotation_and_post_processing/functional_annotation_folder
  stats:                                                     # [6]
    type: Directory?
    outputSource: functional_annotation_and_post_processing/stats

 # << pathways and systems >>
  pathways_systems_folder:
    type: Directory?
    outputSource: functional_annotation_and_post_processing/pathways_systems_folder

 # << pathways and systems from antismash >>
  pathways_systems_folder_antismash:
    type: Directory
    outputSource: antismash/antismash_folder
  pathways_systems_folder_antismash_summary:
    type: Directory?
    outputSource:  functional_annotation_and_post_processing/pathways_systems_folder_antismash_summary

 # << sequence categorisation >>
  sequence-categorisation_folder:                   # [2]
    type: Directory
    outputSource: move_to_seq_cat_folder/out
  rna-count:
    type: File
    outputSource: rna_prediction/LSU-SSU-count

 # << taxonomy summary >>
  taxonomy-summary_folder:
    type: Directory
    outputSource: return_tax_dir/out

 # FAA count
  count_CDS:
    type: int
    outputSource: cgc/count_faa

  optional_tax_file_flag:
    type: File?
    outputSource: no_tax_file_flag/created_file

steps:

# -----------------------------------  << Assign MGYCs >>  -----------------------------------

  count_sequences_fasta:
    run: ../../../utils/count_fasta.cwl
    when: $(inputs.include_protein_assign_bool == true)
    in:
      include_protein_assign_bool: include_protein_assign
      sequences: filtered_fasta
      number: { default: 1 }
    out: [ count ]

  assign_mgyc:
    run: ../../../tools/Assembly/assign_MGYC/assign_mgyc.cwl
    when: $(inputs.include_protein_assign_bool == true)
    in:
      include_protein_assign_bool: include_protein_assign
      input_fasta: filtered_fasta
      mapping: mapping_directory_mgyc
      count: count_sequences_fasta/count
      accession:
        source: filtered_fasta
        valueFrom: $(self.nameroot.split('_')[0])
    out: [ renamed_contigs_fasta ]


# -----------------------------------  << RNA PREDICTION >>  -----------------------------------
  rna_prediction:
    in:
      type: { default: 'assembly'}
      input_sequences: assign_mgyc/renamed_contigs_fasta
      silva_ssu_database: ssu_db
      silva_lsu_database: lsu_db
      silva_ssu_taxonomy: ssu_tax
      silva_lsu_taxonomy: lsu_tax
      silva_ssu_otus: ssu_otus
      silva_lsu_otus: lsu_otus
      ncRNA_ribosomal_models: rfam_models
      ncRNA_ribosomal_model_clans: rfam_model_clans
      pattern_SSU: ssu_label
      pattern_LSU: lsu_label
      pattern_5S: 5s_pattern
      pattern_5.8S: 5.8s_pattern
    out:
      - ncRNA
      - cmsearch_result
      - SSU_folder
      - LSU_folder
      - LSU-SSU-count
      - SSU_fasta
      - LSU_fasta
      - compressed_rnas
      - number_LSU_mapseq
      - number_SSU_mapseq
    run: ../../subworkflows/rna_prediction-sub-wf.cwl

# add no-tax file-flag if there are no lsu and ssu seqs
  no_tax_file_flag:
    when: $(inputs.count_lsu < 3 && inputs.count_ssu < 3)
    run: ../../../utils/touch_file.cwl
    in:
      count_lsu: rna_prediction/number_LSU_mapseq
      count_ssu: rna_prediction/number_SSU_mapseq
      filename: { default: no-tax}
    out: [ created_file ]


# << OTHER ncrnas >>
  other_ncrnas:
    run: ../../subworkflows/other_ncrnas.cwl
    in:
     input_sequences: assign_mgyc/renamed_contigs_fasta
     cmsearch_file: rna_prediction/ncRNA
     other_ncRNA_ribosomal_models: other_ncrna_models
     name_string: { default: 'other_ncrna' }
    out: [ ncrnas ]

# -----------------------------------  << COMBINED GENE CALLER >>  -----------------------------------
  cgc:
    in:
      input_fasta:
        source:
          - assign_mgyc/renamed_contigs_fasta
          - filtered_fasta
        pickValue: first_non_null
      postfixes: CGC_postfixes
      chunk_size: cgc_chunk_size
    out: [ predicted_faa, predicted_ffn, count_faa ]
    run: ../../subworkflows/assembly/CGC-subwf.cwl

# -----------------------------------  << Assign MGYPs >>  -----------------------------------

  assign_mgyp:
    when: $(inputs.include_protein_assign_bool == true)
    run: ../../../tools/Assembly/assign_MGYP/assign_mgyp.cwl
    in:
      include_protein_assign_bool: include_protein_assign
      input_fasta: cgc/predicted_faa
      config: mgyp_config
      release: mgyp_release
      accession:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
      private: private
    out: [ renamed_proteins, stderr_protein_assign ]

# ------------------------- <<ANTISMASH >> -------------------------------
  antismash:
    run: ../../../tools/Assembly/antismash/chunking_antismash_with_conditionals/wf_antismash.cwl
    in:
      input_filtered_fasta: assign_mgyc/renamed_contigs_fasta
      clusters_glossary: clusters_glossary
      final_folder_name: { default: pathways-systems }
    out:
      - antismash_folder
      - antismash_clusters

# -----------------------------------  << STEP FUNCTIONAL ANNOTATION >>  -----------------------------------
# - GFF
# - DIAMOND
# - KEGG pathways, move to pathways-systems
# - Genome Properties
# - tsv -> csv
# - move antismash summary to pathways-systems

  functional_annotation_and_post_processing:
    when: $(inputs.check_value != 0)
    run: ../../subworkflows/assembly/func_ann_and_post_processing-subwf.cwl
    in:
      check_value: cgc/count_faa
      cgc_results_faa:
        source:
          - assign_mgyp/renamed_proteins
          - cgc/predicted_faa
        pickValue: first_non_null
      filtered_fasta: assign_mgyc/renamed_contigs_fasta
      rna_prediction_ncRNA: rna_prediction/ncRNA

      protein_chunk_size_eggnog:  protein_chunk_size_eggnog
      EggNOG_db: EggNOG_db
      EggNOG_diamond_db: EggNOG_diamond_db
      EggNOG_data_dir: EggNOG_data_dir

      protein_chunk_size_hmm: protein_chunk_size_hmm
      func_ann_names_hmmer: func_ann_names_hmmer
      HMM_gathering_bit_score: HMM_gathering_bit_score
      HMM_omit_alignment: HMM_omit_alignment
      HMM_name_database: HMM_name_database
      hmmsearch_header: hmmsearch_header

      protein_chunk_size_IPS: protein_chunk_size_IPS
      func_ann_names_ips: func_ann_names_ips
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
      ips_header: ips_header

      diamond_maxTargetSeqs: diamond_maxTargetSeqs
      diamond_databaseFile: diamond_databaseFile
      Uniref90_db_txt: Uniref90_db_txt
      diamond_header: diamond_header

      antismash_geneclusters_txt: antismash/antismash_clusters
      go_config: go_config

      ko_file: ko_file
      graphs: graphs
      pathways_names: pathways_names
      pathways_classes: pathways_classes

      gp_flatfiles_path: gp_flatfiles_path
    out:
      - functional_annotation_folder
      - stats
      - pathways_systems_folder_antismash_summary
      - pathways_systems_folder

# ----------------------------------- << FINAL STEPS ROOT FOLDER >> -----------------------------------

# index FASTA
  fasta_index:
    run: ../../../tools/Assembly/index_fasta/fasta_index.cwl
    in:
      fasta: assign_mgyc/renamed_contigs_fasta
    out: [fasta_index, fasta_bgz, bgz_index]

# chunking
  chunking_final:
    run: ../../subworkflows/final_chunking.cwl
    in:
      fasta: assign_mgyc/renamed_contigs_fasta
      ffn: cgc/predicted_ffn
      faa:
        source:
          - assign_mgyp/renamed_proteins
          - cgc/predicted_faa
        pickValue: first_non_null
      LSU: rna_prediction/LSU_fasta
      SSU: rna_prediction/SSU_fasta
    out:
      - nucleotide_fasta_chunks                         # fasta, ffn
      - protein_fasta_chunks                            # faa
      - SC_fasta_chunks                                 # LSU, SSU

# gzip
  compression:
    run: ../../../utils/pigz/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        source:
          - rna_prediction/ncRNA                        # cmsearch.all.deoverlapped
          - rna_prediction/cmsearch_result              # cmsearch.all
        linkMerge: merge_flattened
    out: [compressed_file]

# ----------------------------------- << SEQUENCE CATEGORISATION FOLDER >> -----------------------------------
# << move chunked files >>
  move_to_seq_cat_folder:  # LSU and SSU
    run: ../../../utils/return_directory.cwl
    in:
      file_list:
        source:
          - chunking_final/SC_fasta_chunks
          - rna_prediction/compressed_rnas
          - other_ncrnas/ncrnas
        linkMerge: merge_flattened
      dir_name: { default: 'sequence-categorisation' }
    out: [ out ]

# return taxonomy-summary
  return_tax_dir:
    run: ../../../utils/return_directory.cwl
    in:
      dir_list:
        - rna_prediction/SSU_folder
        - rna_prediction/LSU_folder
      dir_name: { default: 'taxonomy-summary' }
    out: [out]


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
