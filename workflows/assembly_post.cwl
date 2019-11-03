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

outputs:
  gp_summary:
    outputSource: genome_properties/summary
    type: File
  gp_summary_csv:
    outputSource: create_csv/csv_result
    type: File
  antismash_final_gbk:
    outputSource: antismash/final_gbk
    type: File
  antismash_final_embl:
    outputSource: antismash/final_embl
    type: File
  antismash_geneclusters_json:
    outputSource: antismash/geneclusters_json
    type: File
  antismash_geneclusters_txt:
    outputSource: antismash/geneclusters_txt
    type: File
  antismash_gff_gz:
    outputSource: antismash_gff/output_gff_gz
    type: File
  antismash_gff_tbi:
    outputSource: antismash_gff/output_gff_index
    type: File
steps:

# << GENOME PROPERTIES >>
  genome_properties:
    run: ../tools/Genome_properties/genome_properties.cwl
    in:
      input_tsv_file: ips_result
      flatfiles_path: gp_flatfiles_path
      GP_txt: {default: genomeProperties.txt}
      name:
        source: fasta
        valueFrom: $(self.nameroot).summary.gprops.tsv
    out: [ summary ]

# change TSV to CSV
  create_csv:
    run: ../utils/make_csv.cwl
    in:
      tab_sep_table: genome_properties/summary
      output_name:
        source: genome_properties/summary
        valueFrom: $(self.nameroot.split('SUMMARY_')[1])
    out: [csv_result]

# << ANTISMASH >>
  antismash:
    run: ../tools/Assembly/antismash/antismash_v4.cwl
    in:
      outdirname: {default: 'antismash_result'}
      input_fasta: fasta
    out: [final_gbk, final_embl, geneclusters_json, geneclusters_txt]

# << GFF for antismash >>
  antismash_gff:
    run: ../tools/Assembly/GFF/antismash_to_gff.cwl
    in:
      antismash_geneclus: antismash/geneclusters_txt
      antismash_embl: antismash/final_embl
      antismash_gc_json: antismash/geneclusters_json
      output_name:
        source: fasta
        valueFrom: $(self.nameroot).antismash.gff
    out: [output_gff_gz, output_gff_index]
