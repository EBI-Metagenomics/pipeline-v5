#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: gather stats from InterProScan
requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 10204  # just a default, could be lowered
hints:
  SoftwareRequirement:
    packages:
      python: {}

inputs:
  ipr_entry_maps:
    type: File
    streamable: true
    format: iana:application/yaml

baseCommand: python

arguments:
  - prefix: -c
    valueFrom: |
      from __future__ import print_function
      import yaml
      ipr_maps = yaml.load(open("$(inputs.ipr_entry_maps.path)", "r"))
      entry2protein = ipr_maps["entry2protein"]
      entry2name = ipr_maps["entry2name"]
      unsortedEntries = []
      for item in entry2protein.items():
          entry = item[0]
          proteins = item[1]
          name = entry2name[entry]
          tuple = (entry, name, len(proteins))
          unsortedEntries.append(tuple)
      sortedEntries = sorted(unsortedEntries, key=lambda item: item[2])
      sortedEntries.reverse()
      for entry in sortedEntries:
          print('"' + entry[0] + '"' + ',' + '"' + entry[1] + '"' + ',' + '"' + str(entry[2]) + '"')

stdout: summary.ipr

outputs:
  ipr_summary: stdout

$namespaces:
 s: http://schema.org/
 iana: https://www.iana.org/assignments/media-types/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"