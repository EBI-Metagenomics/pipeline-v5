#!/usr/bin/env cwl-runner

cwlVersion: v1.0
class: Workflow
label: Subworkflow for mOTUs classification

requirements:
  - class: InlineJavascriptRequirement
  - class: SchemaDefRequirement
    types:
        - $import: ../biom-convert/biom-convert-table.yaml

inputs:
    raw_forward: File
    raw_reverse: File

outputs:
    motus:
        type: File
        outputSource: motus_classification/classifications
    krona_otus:
        type: File
        outputSource: biom_to_tsv/tsv_classifications
    krona_figure:
        type: File
        outputSource: krona_output/html_krona

steps:
    seqprep:
        run: ../tools/SeqPrep/seqprep.cwl
        in:
         forward: raw_forward
         reverse: raw_reverse
        out: [merged, unmerged_forward, unmerged_reverse]

    merge:
        run: ../tools/SeqPrep/seqprep-merge.cwl
        in:
         merged_file: seqprep/merged
         unmergedF_file: seqprep/unmerged_forward
         unmergedR_file: seqprep/unmerged_reverse
        out: [all_merged]

    quality-control:
        run: ../tools/Trimmomatic/Trimmomatic-v0.36.cwl
        in:
          reads: merge/all_merged
          phred: { default: '33' }
          leading: { default: 3 }
          trailing: { default: 3 }
          end_mode: { default: SE }
          minlen: { default: 100 }
          slidingwindow:
            default:
              windowSize: 4
              requiredQuality: 15
        out: [trimmed_reads]

    motus_classification:
        run: ../tools/mOTUs/mOTUs.cwl
        in:
          qc_reads: quality-control/trimmed_reads
        out: [biom_classifications]

    biom_to_tsv:
        run: ../tools/biom-convert/biom-convert.cwl
        in:
          biom: motus_classification/biom_classifications
          table_type: { default: 'Table' }
          tsv: { default: true }
        out: [tsv_classifications]

    krona_output:
        run: ../tools/krona/krona.cwl
        in:
          otu_counts: biom_to_tsv/tsv_classifications
        out: [html_krona]

$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.18.owl
 - https://schema.org/docs/schema_org_rdfa.html

's:author': 'Varsha Kale'
's:copyrightHolder': EMBL - European Bioinformatics Institute
's:license': "https://www.apache.org/licenses/LICENSE-2.0"
