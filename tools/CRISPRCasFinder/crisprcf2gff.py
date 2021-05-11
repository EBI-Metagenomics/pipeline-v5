#!/usr/bin/env python3

# Script to parse a CrisprCasFinder JSON output to extract features as GFF.
# (C) 2021 EMBL - EBI

import json
import argparse

parser = argparse.ArgumentParser(description="Script to parse a CrisprCasFinder JSON output to extract features as GFF")
parser.add_argument("-j", "--json", type=str, help="CrisprCasFinder file (json)")
parser.add_argument("-o", "--out", type=str, help="Output GFF")
args = parser.parse_args()

json_file = args.json
out_file = args.out

crispr_attr = [ "DR_Consensus",
                "Repeat_ID",
                "DR_Length",
                "Spacers",
                "CRISPRDirection",
                "Evidence_Level",
                "Conservation_DRs",
                "Conservation_Spacers"
              ]

def pasteAttr(data, fields):
    attr_list = []
    for field in fields:
        if field in data:
            attr_list.append("{}={}".format(field, data[field]))
    return ";".join(attr_list)


out = open(out_file, "w")
out.write("##gff-version 3\n")

with open(json_file, "r") as json_in:
    data = json.load(json_in)
    for seq in data["Sequences"]:
        chr = seq["Version"]
        if "Crisprs" in seq:
            for crispr in seq["Crisprs"]:
                crispr_id = crispr["Name"]
                crispr_dir = crispr["Potential_Orientation"]
                if not (crispr_dir == '+' or crispr_dir == '-'):
                    crispr_dir = '.'
                
                # Main CRISPR record
                attr = pasteAttr(crispr, crispr_attr) 
                out.write("\t".join([   chr,
                                        "CrisprCasFinder",
                                        "CRISPR",
                                        str(crispr["Start"]),
                                        str(crispr["End"]),
                                        ".",
                                        crispr_dir,
                                        ".",
                                        "ID={};Name={};{}\n".format(
                                                                crispr_id,
                                                                crispr_id,
                                                                attr
                                                            )
                                    ]))
                # Subelements for CRISPR
                num_feature  = 0
                for region in crispr["Regions"]:
                    num_feature += 1
                    ctype = region["Type"]
                    attr  = ";".join([  "ID=" + crispr_id + "_" + ctype + "_" + str(num_feature),
                                        "Parent=" + crispr_id,
                                        "Type=" + ctype 
                                    ])
                    out.write("\t".join([   chr,
                                            "CrisprCasFinder",
                                            "CRISPR_" + ctype,
                                            str(region["Start"]),
                                            str(region["End"]),
                                            ".",
                                            crispr_dir,
                                            ".",
                                            attr + "\n"
                                        ]))
        if "Cas" in seq:
            for cas in seq["Cas"]:
                cas_name = cas["Type"]
                out.write("\t".join([   chr,
                                        "CrisprCasFinder",
                                        cas_name,
                                        str(cas["Start"]),
                                        str(cas["End"]),
                                        ".",
                                        ".",
                                        ".",
                                        "ID={}_{}".format(chr, cas_name) + "\n"
                                    ]))
                for cas_sub in cas["Genes"]:
                    cas_sub_name = cas_sub["Sub_type"]
                    out.write("\t".join([   chr,
                                            "CrisprCasFinder",
                                            cas_sub_name,
                                            str(cas_sub["Start"]),
                                            str(cas_sub["End"]),
                                            ".",
                                            cas_sub["Orientation"],
                                            ".",
                                            "ID={}_{};".format(chr, cas_sub_name) + "Parent={}_{}".format(chr, cas_name) + "\n"
                                        ]))
                            

out.close()