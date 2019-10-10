#!/usr/bin/env python3

from __future__ import print_function
import yaml
import argparse
import sys
import os

def write_summary(maps):
    filename = os.path.basename(maps).split(".")[0]
    outputfilename = filename.split("_")[0]
    func_maps = yaml.safe_load(open(maps, "r"))
    entry2protein = func_maps["entry2protein"]
    entry2name = func_maps["entry2name"]
    unsortedEntries = []
    for item in entry2protein.items():
      entry = item[0]
      proteins = item[1]
      name = entry2name[entry]
      tuple = (entry, name, len(proteins))
      unsortedEntries.append(tuple)
    sortedEntries = sorted(unsortedEntries, key=lambda item: item[2])
    sortedEntries.reverse()
    with open("summary."+outputfilename, "w") as file_out:
        for entry in sortedEntries:
          file_out.write('"' + entry[0] + '"' + ',' + '"' + entry[1] + '"' + ',' + '"' + str(entry[2]) + '"\n')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generates InterProScan summary file")
    parser.add_argument("-i", dest="ipr_maps", help="mapping ipr file from output of functional stats", required=True)
    parser.add_argument("-k", dest="hmm_maps", help="mapping hmm file from output for functional stats", required=True)
    parser.add_argument("-p", dest="pfam_maps", help="mapping pfam file from output for functional stats", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        write_summary(args.ipr_maps)
        write_summary(args.hmm_maps)
        write_summary(args.pfam_maps)
