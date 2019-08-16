#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: "Run taxonomic classification, create OTU table and krona visualisation"

inputs:
  fasta: File
  mapseq_ref: {type: File, secondaryFiles: [.mscluster] }
  mapseq_taxonomy: File
  otu_ref: File
  otu_label:
    type: string


outputs:
  mapseq_classifications:
    type: File
    outputSource: mapseq/classifications

  otu_tsv:
    type: File
    outputSource: classifications_to_otu_counts/otu_counts

  krona_image:
    type: File
    outputSource: visualize_otu_counts/otu_visualization

  otu_txt:
    type: File
    outputSource: classifications_to_otu_counts/krona_otu_counts


steps:
  mapseq:
    run: ../tools/mapseq/mapseq.cwl
    in:
      sequences: fasta
      database: mapseq_ref
      taxonomy: mapseq_taxonomy
    out: [ classifications ]

  classifications_to_otu_counts:
    run: ../tools/mapseq2biom/mapseq2biom.cwl
    in:
       otu_table: otu_ref
       label: otu_label
       query: mapseq/classifications
    out: [ otu_counts, krona_otu_counts ]

  visualize_otu_counts:
    run: ../tools/krona/krona.cwl
    in:
      otu_counts: classifications_to_otu_counts/krona_otu_counts
    out: [ otu_visualization ]
