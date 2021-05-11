#!/usr/bin/env python3

# Script to parse a CrisprCasFinder JSON output to extract Spacer sequences.
# (C) 2021 EMBL - EBI

import json
import argparse

parser = argparse.ArgumentParser(description="Script to parse a CrisprCasFinder JSON output to extract Spacer sequences")
parser.add_argument("-j", "--json", type=str, help="CrisprCasFinder file (json)")
parser.add_argument("-o", "--out", type=str, help="Output Fasta")
args = parser.parse_args()

json_file = args.json
out_file = args.out

out = open(out_file, "w")

with open(json_file, "r") as json_in:
    data = json.load(json_in)
    for seq in data["Sequences"]:
        chr = seq["Version"]
        for crispr in seq["Crisprs"]:
            crispr_name = crispr["Name"]
            num_spacer  = 0
            for region in crispr["Regions"]:
                if region["Type"] == "Spacer":
                    num_spacer += 1
                    start = region["Start"]
                    end   = region["End"]
                    nucl  = region["Sequence"]

                    out.write(">{}_spacer_{} {}:{}-{}\n{}\n".format(crispr_name, num_spacer, chr, start, end, nucl))

out.close()