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
  out: Directory

  mapseq_classifications:
    type: File
    outputSource: edit_empty_tax/mapseq_out

  krona_tsv:
    type: File
    outputSource: edit_empty_tax/otu_out

  krona_txt:
    type: File
    outputSource: edit_empty_tax/biom_out

  krona_image:
    type: File
    outputSource: edit_empty_tax/krona_out
    format: iana:text/html

  mapseq_json:
    type: File
    outputSource: counts_to_json/result

  mapseq_hdf5:
    type: File
    outputSource: counts_to_hdf5/result

expression: |
  ${
    return {"out": {
      "class": "Directory",
      "basename": "my_directory_name",
      "listing": [outputs.mapseq_classifications, outputs.krona_tsv, outputs.krona_txt]
    } };
  }


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
    out: [ otu_tsv, otu_txt ]

  visualize_otu_counts:
    run: ../tools/krona/krona.cwl
    in:
      otu_counts: classifications_to_otu_counts/otu_txt
    out: [ otu_visualization ]

  edit_empty_tax:
    run: ../tools/biom_convert/empty_tax.cwl
    in:
      mapseq: mapseq/classifications
      otutable: classifications_to_otu_counts/otu_tsv
      biomable: classifications_to_otu_counts/otu_txt
      krona: visualize_otu_counts/otu_visualization
    out: [mapseq_out, otu_out, biom_out, krona_out]

  counts_to_hdf5:
    run: ../tools/biom-convert/biom-convert.cwl
    in:
       biom: edit_empty_tax/otu_out
       hdf5: { default: true }
       table_type: { default: 'OTU table' }
    out: [ result ]

  counts_to_json:
    run: ../tools/biom-convert/biom-convert.cwl
    in:
       biom: edit_empty_tax/otu_out
       json: { default: true }
       table_type: { default: 'OTU table' }
    out: [ result ]


$namespaces:
 edam: http://edamontology.org/
 iana: https://www.iana.org/assignments/media-types/