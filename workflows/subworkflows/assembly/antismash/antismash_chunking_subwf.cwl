class: Workflow
cwlVersion: v1.2.0-dev4

label: "WF leaves sequences that length is more than 1000bp, run antismash + gene clusters post-processing, GFF generation"

requirements:
  - class: ResourceRequirement
    ramMin: 5000
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
    filtered_fasta: File
    clusters_glossary: [string, File]
    final_folder_name: string
    split_size: int

outputs:

  antismash_folder_chunking:
    type: Directory
    outputSource: return_antismash_in_folder/out
  antismash_clusters:
    type: File
    outputSource: rename_geneclusters/renamed_file

steps:

  chunking_fasta:
    run: ../../../../utils/result-file-chunker/split_fasta.cwl  #split_subwf_perl.cwl
    in:
      infile: filtered_fasta
      size_limit: split_size
    out: [ chunks ]

  rename_contigs:
    run: ../../../../tools/Assembly/antismash/chunking_antismash_with_conditionals/rename_contigs/rename_contigs.cwl
    scatter: chunks
    in:
      full_fasta: filtered_fasta
      chunks: chunking_fasta/chunks
      accession:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
    out: [ renamed_contigs_in_chunks, names_table ]

  run_antismash:
    run: antismash_subwf.cwl
    scatter: [fasta_file, input_names_table]
    scatterMethod: dotproduct
    in:
      fasta_file: rename_contigs/renamed_contigs_in_chunks
      input_names_table: rename_contigs/names_table
      accession:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
    out:
      - antismash_txt
      - antismash_gbk
      - antismash_embl

  unite_geneclusters_txt:
    run: ../../../../utils/concatenate.cwl
    in:
      files: run_antismash/antismash_txt
      outputFileName: { default: geneclusters.txt }
    out:  [ result ]

  unite_embl:
    run: ../../../../utils/concatenate.cwl
    in:
      files: run_antismash/antismash_embl
      outputFileName:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
      postfix: { default: "_antismash_final.embl" }
    out:  [ result ]

  unite_gbk:
    run: ../../../../utils/concatenate.cwl
    in:
      files: run_antismash/antismash_gbk
      outputFileName:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
      postfix: { default: "_antismash_final.gbk" }
    out:  [ result ]

# << post-processing geneclusters.txt >>
  antismash_summary:
    run: post-processing/reformat_antismash/reformat_antismash.cwl
    doc: |
      Combine the information from the glossary with the united
      antiSMASH geneclusters.txt files.
    in:
      glossary: clusters_glossary
      geneclusters: unite_geneclusters_txt/result
    out: [ reformatted_clusters ]

# << GFF for antismash >>
  antismash_gff:
    run: post-processing/gff_antismash/antismash_to_gff.cwl
    doc: |
      Build a .gff file with the antiSMASH annotations
    in:
      antismash_geneclus: antismash_summary/reformatted_clusters
      antismash_embl: unite_embl/result
      output_name:
        source: filtered_fasta
        valueFrom: $(self.nameroot).antismash.gff
    out: [ output_gff_bgz, output_gff_index ]

# rename reformated geneclusters to ACC_antismash_geneclusters.txt
  rename_geneclusters:
    run: ../../../../utils/move.cwl
    in:
      initial_file: antismash_summary/reformatted_clusters
      out_file_name:
        source: filtered_fasta
        valueFrom: $(self.nameroot)_antismash_geneclusters.txt
    out: [ renamed_file ]

# gzip embl
  gzipped_embl:
    run: ../../../../utils/pigz/gzip.cwl
    in:
      uncompressed_file: unite_embl/result
    out: [ compressed_file ]

# gzip gbk
  gzipped_gbk:
    run: ../../../../utils/pigz/gzip.cwl
    in:
      uncompressed_file: unite_gbk/result
    out: [ compressed_file ]

  return_antismash_in_folder:
    run: ../../../../utils/return_directory/return_directory.cwl
    in:
      file_list:
        - antismash_gff/output_gff_bgz
        - antismash_gff/output_gff_index
        - rename_geneclusters/renamed_file
        - gzipped_embl/compressed_file
        - gzipped_gbk/compressed_file
      dir_name: final_folder_name
    out: [ out ]