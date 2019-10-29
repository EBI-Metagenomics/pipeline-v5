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
  gff:
    outputSource: gff/output_gff
    type: File


#  gp_summary:
#    outputSource: genome_properties/summary
#    type: File

steps:

# << GFF >>
  gff:
    run: ../tools/Assembly/GFF/gff_generation.cwl
    in:
      eggnog_results: eggnog_ann
      input_faa: cds
      output_name:
        source: cds
        valueFrom: $(self.nameroot.split('_CDS')[0]).contigs.annotations.gff
    out: [ output_gff ]



# << GENOME PROPERTIES >>
#  genome_properties:
#    run: ../tools/Genome_properties/genome_properties.cwl
#    in:
#      input_tsv_file: ips_result
#      flatfiles_path: gp_flatfiles_path
#      GP_txt: {default: genomeProperties.txt}
#    out: [ summary ]
