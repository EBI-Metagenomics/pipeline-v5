#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: Subworkflow for mOTUs classification

requirements:
  - class: InlineJavascriptRequirement
#  - class: SchemaDefRequirement
#    types:
#        - $import: ../tools/biom-convert/biom-convert-table.yaml

inputs:
    merged_reads: File

outputs:
    motus_biom:
        type: File
        outputSource: motus_classification/motu_taxonomy
#    krona_otus:
#        type: File
#        outputSource: biom_to_tsv/result
#    krona_figure:
#        type: File
#        outputSource: krona_output/otu_visualization
    motus_tsv:
        type: File
        outputSource: biom_to_tsv/result

steps:

    trim:
          trim_quality_control:
    doc: |
      Low quality trimming (low quality ends and sequences with < quality scores
      less than 15 over a 4 nucleotide wide window are removed)
    run: ../tools/Trimmomatic/Trimmomatic-v0.36-SE.cwl
    in:
      reads1: merged_reads
      phred: { default: '33' }
      leading: { default: 3 }
      trailing: { default: 3 }
      end_mode: { default: SE }
      minlen: { default: 100 }
      slidingwindow:
        default:
          windowSize: 4
          requiredQuality: 15
    out: [reads1_trimmed]

    motus_classification:
        run: ../tools/mOTUs/mOTUs.cwl
        in:
          reads: trim/reads1_trimmed
          threads: 4
        out: [motu_taxonomy]

    biom_to_tsv:
        run: ../tools/biom-convert/biom-convert.cwl
        in:
          biom: motus_classification/motu_taxonomy
          tsv: { default: true }
        out: [result]

#enough hits for a krona visualisation??
#    krona_output:
#        run: ../tools/krona/krona.cwl
#        in:
#          otu_counts: biom_to_tsv/result
#        out: [otu_visualization]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.18.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:author': 'Varsha Kale'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"
