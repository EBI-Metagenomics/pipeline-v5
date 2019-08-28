#!/usr/bin/env cwl-runner
cwlVersion: v1.0
class: CommandLineTool
label: gather stats from InterProScan
#copied from ebi-metagenomics-cwl/tools/ipr_stats.cwl

requirements:
  ResourceRequirement:
    coresMax: 1
    ramMin: 1024  # just a default, could be lowered
hints:
  SoftwareRequirement:
    packages:
      python: {}

inputs:
  iprscan:
    type: File
    streamable: true

baseCommand: python

arguments:
  - prefix: -c
    valueFrom: |
        from __future__ import print_function
        import re
        import json
        import yaml
        accessionPattern = re.compile("(\\S+)_\\d+_\\d+_[+-]")
        match_count = CDS_with_match_number = reads_with_match_count = 0
        cds = set();
        reads = set()
        entry2protein = {};
        entry2name = {}
        for line in open("$(inputs.iprscan.path)", "r"):
            splitLine = line.strip().split('\\t')
            cdsAccessions = splitLine[0].split("|")
            for cdsAccession in cdsAccessions:
                if len(splitLine) >= 13 and splitLine[11].startswith("IPR"):
                    entry = splitLine[11]
                    entry2protein.setdefault(entry, set()).add(cdsAccession)
                    entry2name[entry] = splitLine[12]
                cds.add(cdsAccession)
                readAccessionMatch = re.match(accessionPattern, cdsAccession)
                readAccession = readAccessionMatch.group(1)
                reads.add(readAccession)
                match_count += 1
        CDS_with_match_count = len(cds)
        withFunctionFaaList = sorted(list(cds))
        with open("id_list.txt", "w") as idFile:
            for id in withFunctionFaaList:
                idFile.write(id + "\\n")
        reads_with_match_count = len(reads)
        with open("reads.json", "w") as readsFile:
            json.dump(list(reads), readsFile)
        with open("ipr_entry_maps.yaml", "w") as mapsFile:
            yaml.dump({"entry2protein": entry2protein,
                       "entry2name": entry2name}, mapsFile)
        print(json.dumps({
            "match_count": match_count,
            "CDS_with_match_count": CDS_with_match_count,
            "reads_with_match_count": reads_with_match_count,
            "id_list": {
                "class": "File",
                "path": "$(runtime.outdir)/id_list.txt"},
            "ipr_entry_maps": {
                "class": "File",
                "format": "https://www.iana.org/assignments/media-types/application/yaml",
                "path": "$(runtime.outdir)/ipr_entry_maps.yaml"},
            "reads": {
                "class": "File",
                "format": "https://www.iana.org/assignments/media-types/application/json",
                "path": "$(runtime.outdir)/reads.json"}}))


stdout: cwl.output.json

outputs:
  match_count: int
  CDS_with_match_count: int
  reads_with_match_count: int
  ipr_entry_maps:
    type: File
    streamable: true
    format: iana:application/yaml
  reads:
    type: File
    streamable: true
    format: iana:application/json
  id_list:
    type: File
    streamable: true

$namespaces:
 iana: https://www.iana.org/assignments/media-types/
 s: http://schema.org/
$schemas:
 - https://schema.org/docs/schema_org_rdfa.html

s:license: "https://www.apache.org/licenses/LICENSE-2.0"
s:copyrightHolder: "EMBL - European Bioinformatics Institute"