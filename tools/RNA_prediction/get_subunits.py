#!/usr/bin/env python3

import argparse
import sys
from Bio import SeqIO

LSU_filename = "LSU_extracted.fasta"
SSU_filename = "SSU_extracted.fasta"
FiveS_filename = "5S_extracted.fasta"

SSU_coords = "SSU_coords"
LSU_coords = "LSU_coords"

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="Extract lsu, ssu and 5s")
    parser.add_argument("-i", "--input", dest="input", help="Input fasta file", required=True)
    parser.add_argument("-f", "--fives", dest="fives", help="5S pattern")
    parser.add_argument("-l", "--lsu", dest="lsu", help="LSU pattern", required=True)
    parser.add_argument("-s", "--ssu", dest="ssu", help="SSU pattern", required=True)
    parser.add_argument("-m", "--mode", dest="mode", help="from coords file (coords) or fasta file (fasta)", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        if args.mode == 'fasta':
            with open(SSU_filename, 'w') as out_ssu, open(LSU_filename, 'w') as out_lsu, open(FiveS_filename, 'w') as out_5S:
                for record in SeqIO.parse(args.input, "fasta"):
                    if args.lsu in record.id:
                        SeqIO.write(record, out_lsu, "fasta")
                    elif args.ssu in record.id:
                        SeqIO.write(record, out_ssu, "fasta")
                    elif args.fives in record.id:
                        SeqIO.write(record, out_5S, "fasta")
        elif args.mode == 'coords':
            with open(SSU_coords, 'w') as out_ssu, open(LSU_coords, 'w') as out_lsu, open(args.input, 'r') as input:
                for line in input:
                    if args.lsu in line:
                        out_ssu.write(line)
                    elif args.ssu in line:
                        out_lsu.write(line)