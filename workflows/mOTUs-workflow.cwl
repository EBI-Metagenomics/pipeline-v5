#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: Subworkflow for mOTUs classification

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
        - $import: ../tools/biom-convert/biom-convert-table.yaml

inputs:
    qc_sequences: File
    threads_needed:
        type: int

outputs:
    motus:
        type: File
        outputSource: motus_classification/motu_taxonomy
    krona_otus:
        type: File
        outputSource: biom_to_tsv/result
    krona_figure:
        type: File
        outputSource: krona_output/otu_visualization
    motus_tsv:
        type: File
        outputSource: biom_to_tsv/result

steps:
    motus_classification:
        run: ../tools/mOTUs/mOTUs.cwl
        in:
          reads: qc_sequences
          threads: threads_needed
        out: [motu_taxonomy]

    biom_to_tsv:
        run: ../tools/biom-convert/biom-convert.cwl
        in:
          biom: motus_classification/motu_taxonomy
          table_type: { default: 'Table' }
          tsv: { default: true }
        out: [result]

    krona_output:
        run: ../tools/krona/krona.cwl
        in:
          otu_counts: biom_to_tsv/result
        out: [otu_visualization]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.18.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:author': 'Varsha Kale'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"
