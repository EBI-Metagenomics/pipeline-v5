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
  - class: SubworkflowFeatureRequirement
  - class: MultipleInputFeatureRequirement
  - class: InlineJavascriptRequirement
  - class: StepInputExpressionRequirement
  - class: ScatterFeatureRequirement

inputs:
  ips_result: File
  go_config: File
  fasta: File
  hmmscan_result: File
  rna: File
  cds: File
  graphs: File
  pathways_names: File
  pathways_classes: File
  gp_flatfiles_path: string
  pfam: File
  eggnog_ann: File
  antismash_js: File
  antismash_geneclusters_txt: File
  antismash_final_embl: File

outputs:

  antismash_json:
    outputSource: antismash_json_generation/output_json
    type: File
  antismash_summary:
    outputSource: write_summaries/summary_antismash
    type: File
  ko_summary:
    outputSource: write_summaries/summary_ko
    type: File

  antismash_gff:
    outputSource: antismash_gff/output_gff_gz
    type: File

steps:

# << ANTISMASH >>
  antismash:
    run: ../tools/Assembly/antismash/antismash_v4.cwl
    in:
      outdirname: {default: 'antismash_result'}
      input_fasta: fasta
    out: [final_gbk, final_embl, geneclusters_js, geneclusters_txt]

# << post-processing JS >>
  antismash_json_generation:
    run: ../tools/Assembly/antismash/antismash_json_generation.cwl
    in:
      input_js: antismash/geneclusters_js
      outputname: {default: 'geneclusters.json'}
    out: [output_json]

  write_summaries:
    run: subworkflows/func_summaries.cwl
    in:
       interproscan_annotation: ips_result
       hmmscan_annotation: hmmscan_result
       pfam_annotation: pfam
       antismash_gene_clusters: antismash/geneclusters_txt
       rna: rna
       cds: cds
    out: [summary_go, summary_go_slim, summary_ko, summary_pfam, summary_antismash, stats]

# << GFF for antismash >>
  antismash_gff:
    run: ../tools/Assembly/GFF/antismash_to_gff.cwl
    in:
      antismash_geneclus: antismash/geneclusters_txt
      antismash_embl: antismash/final_embl
      antismash_gc_json: antismash_json_generation/output_json
      output_name:
        source: fasta
        valueFrom: $(self.nameroot).antismash.gff
    out: [output_gff_gz, output_gff_index]