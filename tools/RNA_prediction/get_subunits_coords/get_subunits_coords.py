#!/usr/bin/env python3

import argparse
import sys
import os
import gzip
from Bio import SeqIO


SSU_coords = "SSU_coords"
LSU_coords = "LSU_coords"

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Extract lsu, ssu and 5s")
    parser.add_argument("-i", "--input", dest="input", help="Input fasta file", required=True)
    parser.add_argument("-l", "--lsu", dest="lsu", help="LSU pattern", required=True)
    parser.add_argument("-s", "--ssu", dest="ssu", help="SSU pattern", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()

        with open(SSU_coords, 'w') as out_ssu, open(LSU_coords, 'w') as out_lsu, open(args.input, 'r') as input:
            for line in input:
                if args.lsu in line:
                    out_lsu.write(line)
                elif args.ssu in line:
                    out_ssu.write(line)
    out_ssu.close()
    out_lsu.close()
