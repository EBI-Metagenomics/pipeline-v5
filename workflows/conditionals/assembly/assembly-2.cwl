class: Workflow
cwlVersion: v1.0

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
    filtered_fasta: File

 # << rna prediction >>
    ssu_db: {type: File, secondaryFiles: [.mscluster] }
    lsu_db: {type: File, secondaryFiles: [.mscluster] }
    ssu_tax: [string, File]
    lsu_tax: [string, File]
    ssu_otus: [string, File]
    lsu_otus: [string, File]

    rfam_models:
      type:
        - type: array
          items: [string, File]
    rfam_model_clans: [string, File]
    other_ncrna_models: string[]

    ssu_label: string
    lsu_label: string
    5s_pattern: string
    5.8s_pattern: string

 # << cgc >>
    CGC_config: [string?, File?]
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
    EggNOG_db: [string, File]
    EggNOG_diamond_db: [string, File]
    EggNOG_data_dir: string
    InterProScan_databases: string
    InterProScan_applications: string[]  # ../tools/InterProScan/InterProScan-apps.yaml#apps[]?
    InterProScan_outputFormat: string[]  # ../tools/InterProScan/InterProScan-protein_formats.yaml#protein_formats[]?
    ips_header: string
    ko_file: string

 # << diamond >>
    Uniref90_db_txt: [string, File]
    diamond_maxTargetSeqs: int
    diamond_databaseFile: [string, File]
    diamond_header: string

 # << GO >>
    go_config: [string?, File?]

 # << Pathways >>
    graphs: [string, File]
    pathways_names: [string, File]
    pathways_classes: [string, File]

 # << genome properties >>
    gp_flatfiles_path: string?

 # << antismash summary >>
    clusters_glossary: [string, File]

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
    type: Directory
    outputSource: folder_functional_annotation/functional_annotation_folder
  stats:                                                     # [6]
    outputSource: folder_functional_annotation/stats
    type: Directory

 # << pathways and systems >>
  pathways_systems_folder:
    type: Directory
    outputSource: move_to_pathways_systems_folder/out

 # << pathways and systems from antismash >>
  pathways_systems_folder_antismash:
    type: Directory
    outputSource: antismash/antismash_folder
  pathways_systems_folder_antismash_summary:
    type: Directory
    outputSource:  move_antismash_summary_to_pathways_systems_folder/summary_in_folder

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


steps:

# -----------------------------------  << RNA PREDICTION >>  -----------------------------------
  rna_prediction:
    in:
      input_sequences: filtered_fasta
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
      - compressed_SSU_fasta
      - compressed_LSU_fasta
      - compressed_rnas
    run: ../../subworkflows/rna_prediction-sub-wf.cwl

# << OTHER ncrnas >>
  other_ncrnas:
    run: ../../subworkflows/other_ncrnas.cwl
    in:
     input_sequences: filtered_fasta
     cmsearch_file: rna_prediction/ncRNA
     other_ncRNA_ribosomal_models: other_ncrna_models
     name_string: { default: 'other_ncrna' }
    out: [ ncrnas ]

# -----------------------------------  << COMBINED GENE CALLER >>  -----------------------------------
  cgc:
    in:
      input_fasta: filtered_fasta
      maskfile: rna_prediction/ncRNA
      postfixes: CGC_postfixes
      chunk_size: cgc_chunk_size
    out: [ results ]
    run: ../../subworkflows/assembly/CGC-subwf.cwl

# -----------------------------------  << STEP FUNCTIONAL ANNOTATION >>  -----------------------------------
  functional_annotation:
    run: ../../subworkflows/assembly/functional_annotation.cwl
    in:
      CGC_predicted_proteins:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
      chunk_size_eggnog: protein_chunk_size_eggnog
      chunk_size_hmm: protein_chunk_size_hmm
      chunk_size_IPS: protein_chunk_size_IPS
      name_ips: func_ann_names_ips
      name_hmmer: func_ann_names_hmmer
      HMM_gathering_bit_score: HMM_gathering_bit_score
      HMM_omit_alignment: HMM_omit_alignment
      HMM_database: HMM_name_database
      EggNOG_db: EggNOG_db
      EggNOG_diamond_db: EggNOG_diamond_db
      EggNOG_data_dir: EggNOG_data_dir
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
    out: [ hmm_result, ips_result, eggnog_annotations, eggnog_orthologs ]

# -----------------------------------  << STEP GFF >>  -----------------------------------
  gff:
    run: ../../../tools/Assembly/GFF/gff_generation.cwl
    in:
      ips_results: functional_annotation/ips_result
      eggnog_results: functional_annotation/eggnog_annotations
      input_faa:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
      output_name:
        source: filtered_fasta
        valueFrom: $(self.nameroot).annotations.gff
    out: [ output_gff_gz, output_gff_index ]

# -----------------------------------  << FUNCTIONAL ANNOTATION FOLDER >>  -----------------------------------

# << DIAMOND >>
  diamond:
    run: ../../../tools/Assembly/Diamond/diamond-subwf.cwl
    in:
      queryInputFile:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
      outputFormat: { default: '6' }
      maxTargetSeqs: diamond_maxTargetSeqs
      strand: { default: 'both'}
      databaseFile: diamond_databaseFile
      threads: { default: 32 }
      Uniref90_db_txt: Uniref90_db_txt
      filename:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
    out: [post-processing_output]

# << collect folder >>
  folder_functional_annotation:
    run: ../../subworkflows/assembly/deal_with_functional_annotation.cwl
    in:
      fasta: filtered_fasta
      IPS_table: functional_annotation/ips_result
      diamond_table: diamond/post-processing_output
      hmmscan_table: functional_annotation/hmm_result
      antismash_geneclusters_txt: antismash/antismash_clusters
      rna: rna_prediction/ncRNA
      cds:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
      go_config: go_config
      eggnog_orthologs: functional_annotation/eggnog_orthologs
      eggnog_annotations: functional_annotation/eggnog_annotations
      diamond_header: diamond_header
      hmmsearch_header: hmmsearch_header
      ips_header: ips_header
      output_gff_gz: gff/output_gff_gz
      output_gff_index: gff/output_gff_index
      ko_file: ko_file
    out: [functional_annotation_folder, stats, summary_antismash]

# ----------------------------------- << PATHWAYS and SYSTEMS >> -----------------------------------

# << KEGG PATHWAYS >>
  pathways:
    run: ../../subworkflows/assembly/kegg_analysis.cwl
    in:
      input_table_hmmscan: functional_annotation/hmm_result
      filtered_fasta: filtered_fasta
      outputname:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
      graphs: graphs
      pathways_names: pathways_names
      pathways_classes: pathways_classes
    out: [ kegg_pathways_summary, kegg_contigs_summary]

# << GENOME PROPERTIES >>
  genome_properties:
    run: ../../../tools/Assembly/Genome_properties/genome_properties.cwl
    in:
      input_tsv_file: functional_annotation/ips_result
      flatfiles_path: gp_flatfiles_path
      GP_txt: {default: genomeProperties.txt}
      name:
        source: filtered_fasta
        valueFrom: $(self.nameroot).summary.gprops.tsv
    out: [ summary ]

# << ANTISMASH >>

  antismash:
    run: ../../../tools/Assembly/antismash/chunking_antismash_with_conditionals/wf_antismash.cwl
    in:
      input_filtered_fasta: filtered_fasta
      clusters_glossary: clusters_glossary
      final_folder_name: { default: pathways-systems }
    out:
      - antismash_folder
      - antismash_clusters


# << change TSV to CSV >>
  change_formats_and_names:
    run: ../../subworkflows/assembly/change_formats_and_names.cwl
    in:
      genome_properties_summary: genome_properties/summary
      kegg_summary: pathways/kegg_pathways_summary
      fasta: filtered_fasta
    out: [gp_summary_csv, kegg_summary_csv]

# << move PATHWAYS-SYSTEMS >>
  move_to_pathways_systems_folder:
    run: ../../../utils/return_directory.cwl
    in:
      file_list:
        source:
          - pathways/kegg_contigs_summary                       # kegg contigs.tsv -- not using
          - change_formats_and_names/kegg_summary_csv           # kegg pathways.csv
          - change_formats_and_names/gp_summary_csv             # genome properties.csv
        linkMerge: merge_flattened
      dir_name: { default: pathways-systems }
    out: [ out ]

# << move PATHWAYS-SYSTEMS antismash summary>>
  move_antismash_summary_to_pathways_systems_folder:
    run: ../../../tools/Assembly/antismash/move_antismash_summary/move_antismash_summary.cwl
    in:
      antismash_summary: folder_functional_annotation/summary_antismash
      folder_name: { default: pathways-systems }
    out: [ summary_in_folder ]
# ----------------------------------- << FINAL STEPS ROOT FOLDER >> -----------------------------------

# index FASTA
  fasta_index:
    run: ../../../tools/Assembly/index_fasta/fasta_index.cwl
    in:
      fasta: filtered_fasta
    out: [fasta_index, fasta_bgz, bgz_index]

# chunking
  chunking_final:
    run: ../../subworkflows/final_chunking.cwl
    in:
      fasta: filtered_fasta
      ffn:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.ffn.*$/)).pop() )
      faa:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
      LSU: rna_prediction/compressed_LSU_fasta
      SSU: rna_prediction/compressed_SSU_fasta
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
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"
