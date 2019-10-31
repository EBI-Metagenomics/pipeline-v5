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