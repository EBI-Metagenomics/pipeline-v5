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

outputs:
  antismash_folder:
    type: Directory
    outputSource: antismash/antismash_in_folder
  antismash_clusters:
    type: File?
    outputSource: antismash/reformated_clusters
  add:
    type: Directory
    outputSource: move_antismash_summary_to_pathways_systems_folder/summary_in_folder

steps:

# << count reads pre QC >>
  count_reads:
    in:
      sequences: filtered_fasta
    out: [ count ]
    run: ../../../utils/count_fasta.cwl

  filter_contigs_antismash:
    run: ../../qc-filtering/qc-filtering.cwl
    in:
      seq_file: filtered_fasta
      min_length: { default: 1000 }
      submitted_seq_count: count_reads/count
      stats_file_name: { default: 'qc_summary_antismash' }
      input_file_format: { default: fasta }
    out: [filtered_file]

  antismash:
    run: cwl-s/antismash_v4.cwl
    in:
      outdirname: {default: 'antismash_result'}
      input_fasta: filter_contigs_antismash/filtered_file
      glossary: clusters_glossary
      outname:
        source: filtered_fasta
        valueFrom: $(self.nameroot)
      final_folder: final_folder_name
    out:
      - antismash_in_folder
      - reformated_clusters
      - stderr
      - stdout

  move_antismash_summary_to_pathways_systems_folder:
    run: cwl-s/move_antismash_summary.cwl
    in:
      antismash_summary: antismash/reformated_clusters
      folder_name: final_folder_name
    out: [ summary_in_folder ]





# << post-processing JS >>
#  antismash_json_generation:
#    run: ../../../tools/Assembly/antismash/antismash_json_generation.cwl
#    in:
#      input_js: antismash/geneclusters_js
#      outputname: {default: 'geneclusters.json'}
#    out: [output_json]

# << post-processing geneclusters.txt >>
#  antismash_summary:
#    run: ../../../tools/Assembly/antismash/reformat-antismash.cwl
#    in:
#      glossary: clusters_glossary
#      geneclusters: antismash/geneclusters_txt
#    out: [reformatted_clusters]

# << GFF for antismash >>
#  antismash_gff:
#    run: ../../../tools/Assembly/GFF/antismash_to_gff.cwl
#    in:
#      antismash_geneclus: antismash_summary/reformatted_clusters
#      antismash_embl: antismash/final_embl
#      antismash_gc_json: antismash_json_generation/output_json
#      output_name:
#        source: filtered_fasta
#        valueFrom: $(self.nameroot).antismash.gff
#    out: [output_gff_gz, output_gff_index]