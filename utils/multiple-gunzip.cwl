#!/usr/bin/env cwl-runner
cwlVersion: v1.0

class: CommandLineTool
label: "unzip files"
requirements:
  ResourceRequirement:
    coresMin: 1
    ramMin: 2000  # just a default, could be lowered
  InlineJavascriptRequirement: {}

hints:
 DockerRequirement:
   dockerPull: debian:stable-slim

 SoftwareRequirement:
   packages: { gunzip }

inputs:

 target_reads:
   type: File
   # <<doesn't support by cwltoil>> format: [ edam:format_1929, edam:format_1930 ]  # FASTA or FASTQ
   inputBinding: { position: 1 }
   label: "merged seq prep output"

 forward_unmerged_reads:
   type: File?
   format: edam:format_1930  # FASTQ
   inputBinding: { position: 2 }
   label: "for seqprep result: unmerged forward seqprep output or single end reads"

 reverse_unmerged_reads:
   type: File?
   format: edam:format_1930  # FASTQ
   inputBinding: { position: 3 }
   label: " unmerged reverse seqprep output"

 assembly:
    type: boolean?
    label: "is this an assembly file?"

 reads:
    type: boolean?
    label: "are these raw reads or amplicon reads?"

baseCommand: [ gunzip, -c ]

outputs:
  unzipped_file:
    type: stdout
    format: $(inputs.target_reads.format)

stdout: ${ var ext = "";
       if (inputs.assembly) { ext = inputs.target_reads.nameroot.split('.')[0] + '_FASTA.unfiltered'; }
       if (inputs.reads) { ext = inputs.target_reads.nameroot.split('.')[0] + '_FASTQ.fastq'; }
       return ext; }

$namespaces:
  s: https://schema.org/
  edam: http://edamontology.org/

$schemas:
 - https://schema.org/version/latest/schemaorg-current-http.rdf
 - http://edamontology.org/EDAM_1.16.owl

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder:
    - name: "EMBL - European Bioinformatics Institute"
    - url: "https://www.ebi.ac.uk/"

