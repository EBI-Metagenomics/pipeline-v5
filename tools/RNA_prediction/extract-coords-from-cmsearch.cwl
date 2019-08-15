#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 100  # just a default, could be lowered

inputs:
  infernal_matches:
    label: output from infernal cmsearch
    type: File
    streamable: true

baseCommand: awk

stdout: matched_seqs_with_coords  # helps with cwltool's --cache

arguments:
  - '{print $1"-"$3"/"$8"-"$9" "$8" "$9" "$1}'
  - $(inputs.infernal_matches.path)

outputs:
  matched_seqs_with_coords:
    type: stdout

doc: |
  The awk script takes the output of Infernal's cmsearch so-called fmt=1 mode
  and makes it suitable for use by esl-sfetch, a sequence selector
  
  Reading the user's guide for Infernal, Version 1.1.2; July 2016
  http://eddylab.org/infernal/Userguide.pdf#page=60 we see that
  the relevant fields in the cmsearch output are:
  (column number: explanation)
  1: The name of the target sequence or profile
  3: The name of the query sequence or profile
  8: The start of the alignment of this hit with respect to the
      sequence, numbered 1..L for a sequence of L residues.
  9: The end of the alignment of this hit with respect to the sequence,
      numbered 1..L for a sequence of L residues

  Likewise the format esl-sfetch wants is: <newname> <from> <to> <source seqname>

  Putting it all together we see that the newname (which esl-sfetch with
  output using) is a concatenation of the original name, the sequence
  number, and the coordinates.

$namespaces:
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"
