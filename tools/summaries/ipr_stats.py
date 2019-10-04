#!/usr/bin/env python3
from __future__ import print_function
import yaml
#import os - add output dir?
import argparse
import sys

'''script to generate stats for each funtional analysis. Each function pulls out total number of matches, number of predicted coding sequences with match
and number of contigs with match. Outputs in TSV file. Entry map is generated for InterProScan as input to write IPR summary'''

def ipr_stats(interpro_file):
    match_count = CDS_with_match_number = reads_with_match_count = 0
    cds = set();
    reads = set()
    entry2protein = {};
    entry2name = {}
    go_cds = set()
    go_reads = set()
    go_match_count = go_CDS_match = go_reads_match = 0
    for line in open(interpro_file, "r"):
        splitLine = line.strip().split("\t")
        cdsAccessions = splitLine[0].split("|")
        for cdsAccession in cdsAccessions:
            if len(splitLine) >= 13 and splitLine[11].startswith("IPR"):
                entry = splitLine[11]
                entry2protein.setdefault(entry, set()).add(cdsAccession)
                entry2name[entry] = splitLine[12]
            cds.add(cdsAccession)
            reads.add(cdsAccession.split("_")[0])
            match_count += 1
            if len(splitLine) >= 14 and splitLine[13].startswith("GO"):
                goterms = splitLine[13].split("|")
                go_cds.add(cdsAccession)
                go_reads.add(cdsAccession.split("_")[0])
                go_match_count += len(goterms)
    CDS_with_match_count = len(cds)
    reads_with_match_count = len(reads)
    go_CDS_match = len(go_cds)
    go_reads_match = len(go_reads)
    with open("ipr_entry_maps.yaml", "w") as mapsFile:
        yaml.dump({"entry2protein": entry2protein,
                   "entry2name": entry2name}, mapsFile)
    with open("ipr.stats", "w") as file_out:
        file_out.write("Total InterProScan matches\t"+str(match_count)+"\nPredicted CDS with InterProScan match\t"+str(CDS_with_match_count)+"\nContigs with InterProScan match\t"+str(reads_with_match_count))
    with open("GO.stats", "w") as file_out:
        file_out.write("Total GO matches\t"+str(go_match_count)+"\nPredicted CDS with GO match\t"+str(go_CDS_match)+"\nContigs with GO match\t"+str(go_reads_match))

def hmmscan_stats(hmmscan_file):
    match_count = CDS_with_match_number = reads_with_match_count = 0
    cds = set();
    reads = set()
    for line in open(hmmscan_file, "r"):
        splitLine = line.strip().split("\t")
        cdsAccessions = splitLine[3].split("|")
        for cdsAccession in cdsAccessions:
            cds.add(cdsAccession)
            readAccession = (cdsAccession.split("_"))[0]
            reads.add(readAccession)
        match_count += 1
    CDS_with_match_count = len(cds)
    reads_with_match_count = len(reads)
    with open("hmmscan.stats", "w") as file_out:
        file_out.write("Total KO matches\t"+str(match_count)+"\nPredicted CDS with KO match\t"+str(CDS_with_match_count)+"\nContigs with KO match\t"+str(reads_with_match_count))

def pfam_stats(pfam_file):
    match_count = CDS_with_match_number = reads_with_match_count = 0
    cds = set();
    reads = set()
    for line in open(pfam_file, "r"):
        splitLine = line.strip().split("\t")
        cdsAccessions = splitLine[0].split("|")
        for cdsAccession in cdsAccessions:
            cds.add(cdsAccession)
            readAccession = (cdsAccession.split("_"))[0]
            reads.add(readAccession)
        match_count += 1
    CDS_with_match_count = len(cds)
    reads_with_match_count = len(reads)
    with open("pfam.stats", "w") as file_out:
        file_out.write("Total Pfam matches\t"+str(match_count)+"\nPredicted CDS with Pfam match\t"+str(CDS_with_match_count)+"\nContigs with Pfam match\t"+str(reads_with_match_count))

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generates stats files for all functional analyses")
    parser.add_argument("-i", "--interpro", dest="interpro_file", help="Tab deliminated file with interpro results", required=True)
    parser.add_argument("-k", "--hmmscan", dest="hmmscan_file", help="Tab deliminated file with hmmscan results", required=True)
    parser.add_argument("-p", "--pfam", dest="pfam_file", help="Tab deliminated file with pfam results", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        ipr_stats(args.interpro_file)
        hmmscan_stats(args.hmmscan_file)
        pfam_stats(args.pfam_file)
