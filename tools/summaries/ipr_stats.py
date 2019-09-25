from __future__ import print_function
import re
import json
import yaml

#accessionPattern = re.compile("(\\S+)_\\d")
match_count = CDS_with_match_number = reads_with_match_count = 0
cds = set();
reads = set()
entry2protein = {};
entry2name = {}
for line in open("../interpo_united", "r"):
    splitLine = line.strip().split("\t")
    cdsAccessions = splitLine[0].split("|")
    for cdsAccession in cdsAccessions:
        if len(splitLine) >= 13 and splitLine[11].startswith("IPR"):
            entry = splitLine[11]
            entry2protein.setdefault(entry, set()).add(cdsAccession)
            entry2name[entry] = splitLine[12]
        cds.add(cdsAccession)
        readAccession = (cdsAccession.split("_"))[0]
        #readAccessionMatch = re.match(accessionPattern, cdsAccession)
        #readAccession = readAccessionMatch.group(1)
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

