cwlVersion: v1.0
class: Workflow
label: MGnify pipeline v5.0 (paired end version)

requirements:
 - class: SubworkflowFeatureRequirement

inputs:
  forward_reads:
    type: File
    format: edam:format_1930  # FASTQ
  reverse_reads:
    type: File
    format: edam:format_1930  # FASTQ

  #Rfam models for ribosomal subunits and other ubiquitous ncRNAs
  covariance_models: File[]
  clanInfoFile: File
  cmsearchCores: int
  
outputs:
  processed_nucleotide_reads:
    type: File
    outputSource: trim_and_reformat_reads/trimmed_and_reformatted_reads

  deoverlapped_matches:
    type: File
    outputSource: identify_nc_rna/deoverlapped_matches
 
  qc_stats_summary:
    type: File
    outputSource: generate_qc_stats/summary_out
  qc_stats_seq_len_pbcbin:
    type: File
    outputSource: generate_qc_stats/seq_length_pcbin
  qc_stats_seq_len_bin:
    type: File
    outputSource: generate_qc_stats/seq_length_bin
  qc_stats_seq_len:
    type: File
    outputSource: generate_qc_stats/seq_length_out
  qc_stats_nuc_dist:
    type: File
    outputSource: generate_qc_stats/nucleotide_distribution_out
  qc_stats_gc_pcbin:
    type: File
    outputSource: generate_qc_stats/gc_sum_pcbin
  qc_stats_gc_bin:
    type: File
    outputSource: generate_qc_stats/gc_sum_bin
  qc_stats_gc:
    type: File
    outputSource: generate_qc_stats/gc_sum_out

steps:

  overlap_reads:
    label: Merge paired reads with overlap into single reads
    run: ../tools/SeqPrep/seqprep.cwl
    in:
      forward_reads: forward_reads
      reverse_reads: reverse_reads
    out: [ merged_reads, forward_unmerged_reads, reverse_unmerged_reads ]

  combine_overlaped_and_unmerged_reads:
    label: Merge the outputs of SeqPrep (merged reads, forward and reverse unmerged reads) into a single file
    run: ../tools/SeqPrep/seqprep-merge.cwl
    in: 
      merged_reads: overlap_reads/merged_reads
      forward_unmerged_reads: overlap_reads/forward_unmerged_reads
      reverse_unmerged_reads: overlap_reads/reverse_unmerged_reads
    out: [ merged_with_unmerged_reads ]

  trim_and_reformat_reads:
    label: Trim and reformat reads
    run: trim_and_reformat_reads.cwl
    in:
      reads: combine_overlaped_and_unmerged_reads/merged_with_unmerged_reads
    out:  [ trimmed_and_reformatted_reads ]

  generate_qc_stats:
    label: Generate some post quality control statistics
    run: ../tools/qc-stats/qc-stats.cwl
    in:
      QCed_reads: trim_and_reformat_reads/trimmed_and_reformatted_reads
    out:
      - summary_out
      - seq_length_pcbin
      - seq_length_bin
      - seq_length_out
      - nucleotide_distribution_out
      - gc_sum_pcbin
      - gc_sum_bin
      - gc_sum_out

  identify_nc_rna:
    label: Identifies non-coding RNAs (e.g. rRNA and tRNA) using Rfams covariance models
    run: cmsearch-multimodel-wf.cwl
    in:
      query_sequences: trim_and_reformat_reads/trimmed_and_reformatted_reads
      covariance_models: covariance_models
      clan_info: clanInfoFile
      cores: cmsearchCores
    out: [ deoverlapped_matches ]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
