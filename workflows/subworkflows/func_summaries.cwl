#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: Workflow

requirements:
  SubworkflowFeatureRequirement: {}
  MultipleInputFeatureRequirement: {}
  InlineJavascriptRequirement: {}
  StepInputExpressionRequirement: {}
  ScatterFeatureRequirement: {}

inputs:
  interproscan_annotation: File
  hmmscan_annotation: File
  pfam_annotation: File
  antismash_gene_clusters: File?
  rna: File
  cds: File
  ko_file: [File, string]

outputs:
  stats:
    outputSource: functional_stats/stats
    type: Directory
  summary_ips:
    outputSource: write_summaries/summary_ips
    type: File
  summary_ko:
    outputSource: write_summaries/summary_ko
    type: File
  summary_pfam:
    outputSource: write_summaries/summary_pfam
    type: File
  summary_antismash:
    outputSource: write_summaries/summary_antismash
    type: File?

steps:
  functional_stats:
    run: ../../tools/summaries/functional_stats.cwl
    in:
      interproscan: interproscan_annotation
      hmmscan: hmmscan_annotation
      pfam: pfam_annotation
      cmsearch_file: rna
      cds_file: cds
      antismash_file: antismash_gene_clusters
      ko_file: ko_file
    out: [stats, ips_yaml, ko_yaml, pfam_yaml, antismash_yaml]

  write_summaries:
    run: ../../tools/summaries/write_summaries.cwl
    in:
      ips_entry_maps: functional_stats/ips_yaml
      ips_outname:
        source: cds
        valueFrom: $(self.nameroot.split('_CDS')[0]).summary.ips
      ko_entry_maps: functional_stats/ko_yaml
      ko_outname:
        source: cds
        valueFrom: $(self.nameroot.split('_CDS')[0]).summary.ko
      pfam_entry_maps: functional_stats/pfam_yaml
      pfam_outname:
        source: cds
        valueFrom: $(self.nameroot.split('_CDS')[0]).summary.pfam
      antismash_entry_maps: functional_stats/antismash_yaml
      antismash_outname:
        source: cds
        valueFrom: $(self.nameroot.split('_CDS')[0]).summary.antismash
    out: [summary_ips, summary_ko, summary_pfam, summary_antismash]


$namespaces:
 edam: http://edamontology.org/
 s: http://schema.org/
$schemas:
 - http://edamontology.org/EDAM_1.16.owl
 - https://schema.org/version/latest/schemaorg-current-http.rdf

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
  - name: "EMBL - European Bioinformatics Institute"
  - url: "https://www.ebi.ac.uk/"
