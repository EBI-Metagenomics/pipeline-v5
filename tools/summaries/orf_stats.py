from __future__ import print_function
import re
import json
from Bio import SeqIO

numberOrfs = 0
readsWithOrf = set()
for record in SeqIO.parse("ERZ477576_FASTA.fasta.faa", "fasta"):
    ID = (record.id.split("_"))[0]
    readsWithOrf.add(ID)
    numberOrfs += 1
numberReadsWithOrf = len(readsWithOrf)
with open("reads.json", "w") as readsFile:
    json.dump(list(readsWithOrf), readsFile)
print(json.dumps({
    "numberReadsWithOrf": numberReadsWithOrf,
    "numberOrfs": numberOrfs,
    "readsWithOrf": {
        "class": "File",
        "format": "https://www.iana.org/assignments/media-types/application/json",
        "path": "$(runtime.outdir)/reads.json"}}))
