#!/usr/bin/env python3

import argparse
import sys
from Bio import SeqIO
import os

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Split to chunks")
    parser.add_argument("-i", "--input", dest="input", help="Input fasta file", required=True)
    parser.add_argument("-s", "--size", dest="size", help="Chunk size")

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        cur_number = 0
        currentSequences = []
        ext = os.path.splitext(args.input)[1]
        if ext == '':
            ext = '.fasta'

        for record in SeqIO.parse(args.input, "fasta"):
            cur_number += 1
            currentSequences.append(record)
            if len(currentSequences) == int(args.size):
                fileName = str(cur_number - int(args.size) + 1) + "_" + str(cur_number) + ext
                SeqIO.write(currentSequences, fileName, "fasta")
                currentSequences = []

        # write any remaining sequences
        if len(currentSequences) > 0:
            fileName = str(cur_number - int(args.size) +1) + "_" + str(cur_number) + ext
            SeqIO.write(currentSequences, fileName, "fasta")