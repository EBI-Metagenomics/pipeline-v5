#!/usr/bin/env python3

from __future__ import print_function
import yaml
import argparse
import sys

def write_summary(ipr_maps):
    ipr_maps = yaml.safe_load(open(ipr_maps, "r"))
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
    with open("summary.ipr", "w") as file_out:
        for entry in sortedEntries:
          file_out.write('"' + entry[0] + '"' + ',' + '"' + entry[1] + '"' + ',' + '"' + str(entry[2]) + '"\n')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generates InterProScan summary file")
    parser.add_argument("-i", "--input_file", dest="ipr_maps", help="mapping file from output of functional stats", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        write_summary(args.ipr_maps)
