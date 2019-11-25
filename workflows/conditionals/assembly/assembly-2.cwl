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

    filtered_fasta: File?
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

    #antismash summary
    clusters_glossary: File

outputs:

 # << root folder >>
  compressed_files:                                          # [5] fasta, cmsearch, ncRNA, deoverlapped
    type: File[]
    outputSource: compression/compressed_file
  index_fasta_file:                                          # [1] fasta.bgz.fai
    type: File
    outputSource: fasta_index/fasta_index
  bgzip_fasta_file:                                          # [1] fasta.bgz
    type: File
    outputSource: fasta_index/fasta_bgz
  chunking_nucleotides:                                      # [2] fasta, ffn
    type: File[]
    outputSource: chunking_final/nucleotide_fasta_chunks
  chunking_proteins:                                         # [1] faa
    type: File[]
    outputSource: chunking_final/protein_fasta_chunks

 # << functional annotation >>
  functional_annotation_folder:                              # [15]
    type: Directory
    outputSource: folder_functional_annotation/functional_annotation_folder
  stats:                                                     # [6]
    outputSource: folder_functional_annotation/stats
    type: Directory

 # << pathways and systems >>
  pathways_systems_folder:                                   # [~10]
    type: Directory
    outputSource: move_to_pathways_systems_folder/out

 # << sequence categorisation >>
  sequence-categorisation_folder:                            # [6]
    type: Directory
    outputSource: rna_prediction/sequence-categorisation
#  sequence-categorisation_SSU_LSU:                           # [2]
#    type: Directory
#    outputSource: rna_prediction/sequence-categorisation_two
  sequence-categorisation_SSU_LSU_chunked:                   # [2]
    type: Directory
    outputSource: move_to_seq_cat_folder/out
  other_rna:                                                 # [?]
    type: Directory
    outputSource: other_ncrnas/ncrnas

 # << taxonomy summary >>
  LSU_folder:                                                # [6]
    type: Directory
    outputSource: rna_prediction/LSU_folder
  SSU_folder:                                                # [6]
    type: Directory
    outputSource: rna_prediction/SSU_folder

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
      - sequence-categorisation
#      - sequence-categorisation_two
      - SSU_fasta_file
      - LSU_fasta_file
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
      seq_type: { default: 'a' }
      maskfile: rna_prediction/ncRNA
      config: CGC_config
      outdir: { default: 'CGC-output' }
      postfixes: CGC_postfixes
      chunk_size: cgc_chunk_size
    out: [ results ]
    run: ../../../tools/Combined_gene_caller/CGC-subwf.cwl

# -----------------------------------  << STEP FUNCTIONAL ANNOTATION >>  -----------------------------------
  functional_annotation:
    run: ../../subworkflows/functional_annotation.cwl
    in:
      CGC_predicted_proteins:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
      chunk_size: fa_chunk_size
      name_ips: func_ann_names_ips
      name_hmmscan: func_ann_names_hmmscan
      HMMSCAN_gathering_bit_score: HMMSCAN_gathering_bit_score
      HMMSCAN_omit_alignment: HMMSCAN_omit_alignment
      HMMSCAN_name_database: HMMSCAN_name_database
      HMMSCAN_data: HMMSCAN_data
      EggNOG_db: EggNOG_db
      EggNOG_diamond_db: EggNOG_diamond_db
      EggNOG_data_dir: EggNOG_data_dir
      InterProScan_databases: InterProScan_databases
      InterProScan_applications: InterProScan_applications
      InterProScan_outputFormat: InterProScan_outputFormat
    out: [ hmmscan_result, ips_result, eggnog_annotations, eggnog_orthologs ]

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
        valueFrom: $(self.nameroot).contigs.annotations.gff
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
      filename: filtered_fasta
    out: [post-processing_output]

# << collect folder >>
  folder_functional_annotation:
    run: ../../subworkflows/assembly/deal_with_functional_annotation.cwl
    in:
      fasta: filtered_fasta
      IPS_table: functional_annotation/ips_result
      diamond_table: diamond/post-processing_output
      hmmscan_table: functional_annotation/hmmscan_result
      antismash_geneclusters_txt: antismash/geneclusters_txt
      rna: rna_prediction/ncRNA
      cds:
        source: cgc/results
        valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
      go_config: go_config
      eggnog_orthologs: functional_annotation/eggnog_orthologs
      eggnog_annotations: functional_annotation/eggnog_annotations
      diamond_header: diamond_header
      hmmscan_header: hmmscan_header
      ips_header: ips_header
      output_gff_gz: gff/output_gff_gz
      output_gff_index: gff/output_gff_index
    out: [functional_annotation_folder, stats, summary_antismash]

# ----------------------------------- << PATHWAYS and SYSTEMS >> -----------------------------------

# << KEGG PATHWAYS >>
  pathways:
    run: ../../subworkflows/assembly/kegg_analysis.cwl
    in:
      input_table_hmmscan: functional_annotation/hmmscan_result
      outputname:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
      graphs: graphs
      pathways_names: pathways_names
      pathways_classes: pathways_classes
    out: [ kegg_pathways_summary, kegg_contigs_summary]

# << PFAM >>
  pfam:
    run: ../../../tools/Pfam-Parse/pfam_annotations.cwl
    in:
      interpro: functional_annotation/ips_result
      outputname:
        source: filtered_fasta
        valueFrom: $(self.nameroot).pfam
    out: [annotations]

# << summaries and stats IPS, HMMScan, Pfam >>
  write_summaries:
    run: ../../subworkflows/func_summaries.cwl
    in:
       interproscan_annotation: functional_annotation/ips_result
       hmmscan_annotation: functional_annotation/hmmscan_result
       pfam_annotation: pfam/annotations
       antismash_gene_clusters: antismash_summary/reformatted_clusters
       rna: rna_prediction/ncRNA
       cds:
         source: cgc/results
         valueFrom: $( self.filter(file => !!file.basename.match(/^.*.faa.*$/)).pop() )
    out: [summary_ips, summary_ko, summary_pfam, summary_antismash, stats]

# << GENOME PROPERTIES >>
  genome_properties:
    run: ../../../tools/Genome_properties/genome_properties.cwl
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
    run: ../../../tools/Assembly/antismash/antismash_v4.cwl
    in:
      outdirname: {default: 'antismash_result'}
      input_fasta: filtered_fasta
    out: [final_gbk, final_embl, geneclusters_js, geneclusters_txt]

# << post-processing JS >>
  antismash_json_generation:
    run: ../../../tools/Assembly/antismash/antismash_json_generation.cwl
    in:
      input_js: antismash/geneclusters_js
      outputname: {default: 'geneclusters.json'}
    out: [output_json]

# << post-processing geneclusters.txt >>
  antismash_summary:
    run: ../../../tools/Assembly/antismash/reformat-antismash.cwl
    in:
      glossary: clusters_glossary
      geneclusters: antismash/geneclusters_txt
    out: [reformatted_clusters]

# << GFF for antismash >>
  antismash_gff:
    run: ../../../tools/Assembly/GFF/antismash_to_gff.cwl
    in:
      antismash_geneclus: antismash_summary/reformatted_clusters
      antismash_embl: antismash/final_embl
      antismash_gc_json: antismash_json_generation/output_json
      output_name:
        source: filtered_fasta
        valueFrom: $(self.nameroot).antismash.gff
    out: [output_gff_gz, output_gff_index]

# << change TSV to CSV; move files for pathways & systems >>
  change_formats_and_names:
    run: ../../subworkflows/change_formats_and_names.cwl
    in:
      genome_properties_summary: genome_properties/summary
      kegg_summary: pathways/kegg_pathways_summary
      antismash_gbk: antismash/final_gbk
      antismash_embl: antismash/final_embl
      antismash_geneclusters: antismash_summary/reformatted_clusters
      fasta: filtered_fasta
    out: [gp_summary_csv, kegg_summary_csv, antismash_gbk, antismash_embl, antismash_gclust]

# << gzip pathways and systems files >>
  compression_pathways_systems:
    run: ../../../utils/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        source:
          - change_formats_and_names/antismash_gbk
          - change_formats_and_names/antismash_embl
        linkMerge: merge_flattened
    out: [compressed_file]

# << move PATHWAYS-SYSTEMS >>
  move_to_pathways_systems_folder:
    run: ../../../utils/return_directory.cwl
    in:
      list:
        source:
          - change_formats_and_names/kegg_summary_csv           # kegg pathways.csv
          - change_formats_and_names/antismash_gclust           # geneclusters.txt
          - pathways/kegg_contigs_summary                       # kegg contigs.tsv -- not using
          - change_formats_and_names/gp_summary_csv             # genome properties.csv
          - compression_pathways_systems/compressed_file        # antismash GBK and EMBL
          - antismash_gff/output_gff_gz                         # antismash gff.gz
          - antismash_gff/output_gff_index                      # antismash gff.tbi
          - folder_functional_annotation/summary_antismash                   # antismash summary
        linkMerge: merge_flattened
      dir_name: { default: pathways-systems }
    out: [ out ]

# ----------------------------------- << FINAL STEPS ROOT FOLDER >> -----------------------------------

# index FASTA
  fasta_index:
    run: ../../../utils/fasta_index.cwl
    in:
      fasta: filtered_fasta
    out: [fasta_index, fasta_bgz]

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
      LSU: rna_prediction/LSU_fasta_file
      SSU: rna_prediction/SSU_fasta_file
    out:
      - nucleotide_fasta_chunks                         # fasta, ffn
      - protein_fasta_chunks                            # faa
      - SC_fasta_chunks                                 # LSU, SSU

# gzip
  compression:
    run: ../../../utils/gzip.cwl
    scatter: uncompressed_file
    in:
      uncompressed_file:
        source:
          - filtered_fasta                              # _FASTA
          - rna_prediction/ncRNA                        # cmsearch.all.deoverlapped
          - rna_prediction/cmsearch_result              # cmsearch.all
        linkMerge: merge_flattened
    out: [compressed_file]

# ----------------------------------- << SEQUENCE CATEGORISATION FOLDER >> -----------------------------------
# << move chunked files >>
  move_to_seq_cat_folder:  # LSU and SSU
    run: ../../../utils/return_directory.cwl
    in:
      list: chunking_final/SC_fasta_chunks
      dir_name: { default: sequence-categorisation }
    out: [ out ]