#!/usr/bin/env python3

from __future__ import print_function
import yaml
import argparse
import sys
import os

def write_summary(maps, outputfilename):

    func_maps = yaml.safe_load(open(maps, "r"))
    entry2protein = func_maps["entry2protein"]
    entry2name = func_maps["entry2name"]
    unsortedEntries = []
    for item in entry2protein.items():
        entry = item[0]
        proteins = item[1]
        if entry2name == {}:
            tuple = (entry, len(proteins))
            item_no = 1
        else:
            name = entry2name[entry]
            tuple = (entry, name, len(proteins))
            item_no = 2
        unsortedEntries.append(tuple)
    sortedEntries = sorted(unsortedEntries, key=lambda item:item[item_no])
    sortedEntries.reverse()
    with open(outputfilename, "w") as file_out:
        for entry in sortedEntries:
          file_out.write('"' + '","'.join([str(i) for i in entry]) + '"\n')


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generates InterProScan, Pfam and KEGG ortholog summary count files")
    parser.add_argument("-i", "--interproscan", dest="interproscan", help="interproscan predicted seqs", required=True)
    parser.add_argument("-k", "--hmmscan", dest="hmmscan", help="hmmscan predicted seqs", required=True)
    parser.add_argument("-p", "--pfam", dest="pfam", help="pfam annotation predicted seqs", required=True)
    parser.add_argument("-a", "--antismash", dest="antismash", help="antismash gene clusters", required=False)
    parser.add_argument("-x", "--ips-name", dest="ips_out_name", help="ips_out_name", required=True)
    parser.add_argument("-y", "--ko-name", dest="ko_out_name", help="ko_out_name", required=True)
    parser.add_argument("-z", "--pfam-name", dest="pfam_out_name", help="pfam_out_name", required=True)
    parser.add_argument("-w", "--antismash-name", dest="antismash_out_name", help="antismash_out_name", required=False)
    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        write_summary(args.interproscan, args.ips_out_name)  # IPS
        write_summary(args.hmmscan, args.ko_out_name)  # KO
        write_summary(args.pfam, args.pfam_out_name)  # Pram
        write_summary(args.antismash, args.antismash_out_name) #geneclusters
