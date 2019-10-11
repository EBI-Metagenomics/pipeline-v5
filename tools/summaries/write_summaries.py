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
          file_out.write('"' + '","'.join([str(i) for i in entry]) + '"\n')

if __name__ == "__main__":
   parser = argparse.ArgumentParser(description="Generates InterProScan, Pfam and KEGG ortholog summary count files")
   parser.add_argument("files", help="list of input files", default=[sys.stdin], nargs='+')
   if len(sys.argv) == 1:
       parser.print_help()
   else:
       args = parser.parse_args()
       for file in args.files:
           write_summary(file)

