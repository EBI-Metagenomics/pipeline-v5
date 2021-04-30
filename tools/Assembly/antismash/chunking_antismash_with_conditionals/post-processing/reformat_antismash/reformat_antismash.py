#!/usr/bin/env python3

import argparse
import sys

def cluster_dict(glossary):
    cluster_glossary = {}
    with open(glossary, "r") as long_names:
        for line in long_names:
            if not line.startswith("Label"):
                splitName = line.strip().split("\t")
                cluster_glossary[splitName[0]] = splitName[1]
    return cluster_glossary


def reformat(input_file, glossary, outfile):
    with open(input_file, "r") as clusters:
        for line in clusters:
            splitLine = line.strip().split("\t")
            bgc = splitLine[2]
            bgc = bgc.replace("cf_fatty_acid", "fatty_acid")
            bgc = bgc.replace("cf_saccharide", "saccharide")
            print(bgc)
            if bgc in glossary:
                outfile.write("\t".join(splitLine[:2]) + "\t" + bgc + "\t" + "\t".join(splitLine[3:]) + "\t" + glossary[bgc] + "\n")
            else:
                for key in glossary:
                    if key in bgc:
                        outfile.write("\t".join(splitLine[:2]) + "\t" + key + "\t" + "\t".join(splitLine[3:]) + "\t" + glossary[key] + "\n")

if __name__ == "__main__":
    # FIXME: this script could use some more documentation
    #        for example: why the rename from cf_fatty_acid to fatty_acid?
    parser = argparse.ArgumentParser(description="Find multiple bgc hits in one line and separate")
    parser.add_argument("-a", "--antismash", dest="antismash", help="antismash gene clusters", required=True)
    parser.add_argument("-g", "--glossary", dest="glossary", help="tsv mapping gene clusters to full names", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        with open("geneclusters-summary.txt", "w") as reformatted:
            longNames = cluster_dict(args.glossary)
            reformat(args.antismash, longNames, reformatted)



