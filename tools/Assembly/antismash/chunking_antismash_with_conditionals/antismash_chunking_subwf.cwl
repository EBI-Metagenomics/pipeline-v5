class: Workflow
cwlVersion: v1.2.0-dev2

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
    clusters_glossary: File
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

  calc_chunking_number:
    run: ../../../../utils/count_fasta.cwl
    in:
      sequences: filtered_fasta
      number: split_size
    out: [ count ]

  chunking_fasta:
    run: ../../../chunks/dna_chunker/fasta_chunker.cwl
    in:
      seqs: filtered_fasta
      chunk_size: calc_chunking_number/count
      number_of_output_files: { default: True }
      same_number_of_residues: { default: True }
    out: [ chunks ]

  run_antismash:
    run: antismash_v4.cwl
    scatter: input_fasta
    in:
      input_fasta: chunking_fasta/chunks
      outdirname: { default: antismash_result}
    out:
      - geneclusters_js
      - geneclusters_txt
      - embl_file
      - gbk_file

  unite_geneclusters_js:
    run: ../../../../utils/concatenate.cwl
    in:
      files: run_antismash/geneclusters_js
      outputFileName: { default: geneclusters.js }
    out:  [ result ]

  unite_geneclusters_txt:
    run: ../../../../utils/concatenate.cwl
    in:
      files: run_antismash/geneclusters_txt
      outputFileName: { default: geneclusters.txt }
    out:  [ result ]

  unite_embl:
    run: ../../../../utils/concatenate.cwl
    in:
      files: run_antismash/embl_file
      outputFileName:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
      postfix: { default: "_antismash_final.embl" }
    out:  [ result ]

  unite_gbk:
    run: ../../../../utils/concatenate.cwl
    in:
      files: run_antismash/gbk_file
      outputFileName:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
      postfix: { default: "_antismash_final.gbk" }
    out:  [ result ]


# << post-processing JS >>
  antismash_json_generation:
    run: antismash_json_generation.cwl
    in:
      input_js: unite_geneclusters_js/result
      outputname: {default: 'geneclusters.json'}
    out: [ output_json ]

# << post-processing geneclusters.txt >>
  antismash_summary:
    run: reformat-antismash.cwl
    in:
      glossary: clusters_glossary
      geneclusters: unite_geneclusters_txt/result
    out: [ reformatted_clusters ]

# << GFF for antismash >>
  antismash_gff:
    run: ../../GFF/antismash_to_gff.cwl
    in:
      antismash_geneclus: antismash_summary/reformatted_clusters
      antismash_embl: unite_embl/result
      antismash_gc_json: antismash_json_generation/output_json
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
    run: ../../../../utils/gzip.cwl
    in:
      uncompressed_file: unite_embl/result
    out: [ compressed_file ]

# gzip gbk
  gzipped_gbk:
    run: ../../../../utils/gzip.cwl
    in:
      uncompressed_file: unite_gbk/result
    out: [ compressed_file ]

  return_antismash_in_folder:
    run: ../../../../utils/return_directory.cwl
    in:
      file_list:
        - antismash_gff/output_gff_bgz
        - antismash_gff/output_gff_index
        - rename_geneclusters/renamed_file
        - gzipped_embl/compressed_file
        - gzipped_gbk/compressed_file
      dir_name: final_folder_name
    out: [ out ]