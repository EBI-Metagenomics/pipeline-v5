cwlVersion: v1.0
class: Workflow
label: EMG core analysis

requirements:
 - class: StepInputExpressionRequirement
 - class: SubworkflowFeatureRequirement
 - class: SchemaDefRequirement
   types: 
     - $import: ../tools/FragGeneScan-model.yaml
     - $import: ../tools/InterProScan-apps.yaml
     - $import: ../tools/InterProScan-protein_formats.yaml
     - $import: ../tools/esl-reformat-replace.yaml
     - $import: ../tools/biom-convert-table.yaml
     - $import: ../tools/trimmomatic-sliding_window.yaml
     - $import: ../tools/trimmomatic-end_mode.yaml
     - $import: ../tools/trimmomatic-phred.yaml
      

inputs:
  sequencing_run_id: string
  input_sequences:
    type: File
    format: edam:format_1929  # FASTA
  ncRNA_ribosomal_models: File[]
  ncRNA_ribosomal_model_clans: File
  ncRNA_other_models: File[]
  ncRNA_other_model_clans: File
  fraggenescan_model: ../tools/FragGeneScan-model.yaml#model
  mapseq_ref:
    type: File
    format: edam:format_1929  # FASTA
    secondaryFiles: .mscluster
  mapseq_taxonomy: File
  go_summary_config: File

outputs:  

  #All of the sequence file QC stats
  qc_stats_summary:
    type: File
    outputSource: sequence_stats/summary_out
  qc_stats_seq_len_pcbin:
    type: File
    outputSource: sequence_stats/seq_length_pcbin
  qc_stats_seq_len_bin:
    type: File
    outputSource: sequence_stats/seq_length_bin
  qc_stats_seq_len:
    type: File
    outputSource: sequence_stats/seq_length_out 
  qc_stats_nuc_dist:
    type: File
    outputSource: sequence_stats/nucleotide_distribution_out
  qc_stats_gc_pcbin:
    type: File
    outputSource: sequence_stats/gc_sum_pcbin
  qc_stats_gc_bin:
    type: File
    outputSource: sequence_stats/gc_sum_bin
  qc_stats_gc:
    type: File
    outputSource: sequence_stats/gc_sum_out

  #Taxonomic analysis step
  SSU_sequences:
    type: File
    outputSource: extract_SSUs/sequences

  ssu_classifications:
    type: File
    outputSource: classify_SSUs/classifications

  #Repeat extraction for LSU
  LSU_sequences:
    type: File
    outputSource: extract_LSUs/sequences

  #Repeat  extract for 5S
  5S_sequences:
    type: File
    outputSource: extract_5Ss/sequences


  #The predicted proteins and their annotations
  predicted_CDS:
    type: File
    outputSource: ORF_prediction/predicted_CDS_aa
  #The GO terms, full and slimmed.
  go_summary:
    type: File
    outputSource: functional_analysis/go_summary
  go_summary_slim:
    type: File
    outputSource: functional_analysis/go_summary_slim

  functional_annotations:
    type: File
    outputSource: functional_analysis/functional_annotations

  #Taxonomic visualisation step
  ssu_otu_visualization:
    type: File
    outputSource: visualize_otu_counts/otu_visualization 

  ssu_otu_counts_hdf5:
    type: File
    outputSource: convert_otu_counts_to_hdf5/result 
  
  ssu_otu_counts_json:
    type: File
    outputSource: convert_otu_counts_to_json/result 

  #TODO - repeat taxonomy LSU

    

  #Non-coding RNA analysis
  other_ncRNAs:
    type: File
    outputSource: find_other_ncRNAs/matches
  
  #TODO - Extract these into a single file 
  

  #TODO - check all the outputs
  #Sequence cat
  #Global Summary files
  match_count:
    type: int
    outputSource: ipr_stats/match_count

  CDS_with_match_count:
    type: int
    outputSource: ipr_stats/CDS_with_match_count

  reads_with_match_count:
    type: int
    outputSource: ipr_stats/reads_with_match_count

  stats_reads:
    type: File
    outputSource: ipr_stats/reads

  numberReadsWithOrf:
    type: int
    outputSource: orf_stats/numberReadsWithOrf
  
  numberOrfs:
    type: int
    outputSource: orf_stats/numberOrfs

  readsWithOrf:
    type: File
    outputSource: orf_stats/readsWithOrf

  interproscan:
    type: File
    outputSource: categorisation/interproscan

  no_functions_seqs:
    type: File
    outputSource: categorisation/no_functions_seqs
   
  pCDS_seqs:
    type: File
    outputSource: categorisation/pCDS_seqs

steps:
  #sequence QC stats
  sequence_stats:
    run: ../tools/qc-stats.cwl
    in: 
      QCed_reads: input_sequences
    out: 
      - summary_out
      - seq_length_pcbin
      - seq_length_bin
      - seq_length_out 
      - nucleotide_distribution_out
      - gc_sum_pcbin
      - gc_sum_bin
      - gc_sum_out


  #Ribosomal ncRNA identification
  find_ribosomal_ncRNAs:
    run:  cmsearch-multimodel.cwl 
    in: 
      query_sequences: input_sequences 
      covariance_models: ncRNA_ribosomal_models
      clan_info: ncRNA_ribosomal_model_clans
    out: [ matches ]


  
  index_reads:
    run: ../tools/esl-sfetch-index.cwl
    in:
      sequences: input_sequences 
    out: [ sequences_with_index ]
  
  #SSU classification
  get_SSU_coords:
    run: ../tools/SSU-from-tablehits.cwl
    in:
      table_hits: find_ribosomal_ncRNAs/matches
    out: [ SSU_coordinates ]

  extract_SSUs:
    run: ../tools/esl-sfetch-manyseqs.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      names: get_SSU_coords/SSU_coordinates
      names_contain_subseq_coords: { default: true }
    out: [ sequences ]

  classify_SSUs:
    run: ../tools/mapseq.cwl
    in:
      sequences: extract_SSUs/sequences
      database: mapseq_ref
      taxonomy: mapseq_taxonomy
    out: [ classifications ]


  #LSU classification
  get_LSU_coords:
    run: ../tools/LSU-from-tablehits.cwl
    in:
      table_hits: find_ribosomal_ncRNAs/matches
    out: [ LSU_coordinates ]

  extract_LSUs:
    run: ../tools/esl-sfetch-manyseqs.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      names: get_LSU_coords/LSU_coordinates
      names_contain_subseq_coords: { default: true }
    out: [ sequences ]




  #Visualisation of taxonomic classification
  convert_classifications_to_otu_counts:
    run: ../tools/mapseq2biom.cwl
    in:
       otu_table: mapseq_taxonomy
       label: sequencing_run_id
       query: classify_SSUs/classifications
    out: [ otu_counts, krona_otu_counts ]

  visualize_otu_counts:
    run: ../tools/krona.cwl
    in:
      otu_counts: convert_classifications_to_otu_counts/krona_otu_counts
    out: [ otu_visualization ]

  convert_otu_counts_to_hdf5:
    run: ../tools/biom-convert.cwl
    in:
       biom: convert_classifications_to_otu_counts/otu_counts
       hdf5: { default: true }
       table_type: { default: OTU table }
    out: [ result ]

  convert_otu_counts_to_json:
    run: ../tools/biom-convert.cwl
    in:
       biom: convert_classifications_to_otu_counts/otu_counts
       json: { default: true }
       table_type: { default: OTU table }
    out: [ result ]


  #5S extraction
  get_5S_coords:
    run: ../tools/5S-from-tablehits.cwl
    in:
      table_hits: find_ribosomal_ncRNAs/matches
    out: [ 5S_coordinates ]

  extract_5Ss:
    run: ../tools/esl-sfetch-manyseqs.cwl
    in:
      indexed_sequences: index_reads/sequences_with_index
      names: get_5S_coords/5S_coordinates
      names_contain_subseq_coords: { default: true }
    out: [ sequences ]



  #Find other ubquitious ncRNAs
  find_other_ncRNAs:
    run:  cmsearch-multimodel.cwl 
    in: 
      query_sequences: input_sequences
      covariance_models: ncRNA_other_models
      clan_info: ncRNA_other_model_clans
    out: [ matches ]

  
  #TODO - need to extract ncRNA sequences 
  #TODO - need to think about summary file for ncRNAs
  #TODO - Extra tRNAs and then run them through tRNAScan-se 
  #TODO - Longer term ITS1 identification
  #TODO - Remove ORFs that overlaps with ncRNA predictions >4 bp


  #Protein identification and tidying up
  ORF_prediction:
    run: orf_prediction.cwl
    in:
      sequence: input_sequences
      completeSeq: { default: false }
      model: fraggenescan_model
    out: [ predicted_CDS_aa ]

  remove_asterisks_and_reformat:
    run: ../tools/esl-reformat.cwl
    in:
      sequences: ORF_prediction/predicted_CDS_aa
      replace: { default: { find: '*', replace: X } }
    out: [ reformatted_sequences ]


  #Can we go full fat InterPro in the future?
  functional_analysis:
    doc: |
      Matches are generated against predicted CDS, using a sub set of databases
      (Pfam, TIGRFAM, PRINTS, PROSITE patterns, Gene3d) from InterPro. 
    run: functional_analysis.cwl
    in:
      predicted_CDS: remove_asterisks_and_reformat/reformatted_sequences
      go_summary_config: go_summary_config
    out: [ functional_annotations, go_summary, go_summary_slim ]  
   
  #Sequence catagorisation & summary steps.
  ipr_stats:
    run: ../tools/ipr_stats.cwl
    in:
      iprscan: functional_analysis/functional_annotations
    out:
      - match_count
      - CDS_with_match_count
      - reads_with_match_count
      - reads
      - id_list

  orf_stats:
    run: ../tools/orf_stats.cwl
    in:
      orfs: ORF_prediction/predicted_CDS_aa
    out: [ numberReadsWithOrf, numberOrfs, readsWithOrf ]

  categorisation:
    run: ../tools/create_categorisations.cwl
    in:
      seqs: extract_SSUs/sequences
      ipr_idset: ipr_stats/reads
      cds_idset: orf_stats/readsWithOrf
    out: [ interproscan, pCDS_seqs, no_functions_seqs ]
    
$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
