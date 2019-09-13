#!/usr/bin/env python3

import argparse
import sys
from Bio import SeqIO



if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Split to chunks")
    parser.add_argument("-i", "--input", dest="input", help="Input fasta file", required=True)
    parser.add_argument("-s", "--size", dest="size", help="Chunk size")

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()

        currentSequences = []
        for record in SeqIO.parse(args.input, "fasta"):
            currentSequences.append(record)
            if len(currentSequences) == args.size:
                fileName = currentSequences[0].id + "_" + currentSequences[-1].id + ".fasta"
                for char in ["/", " ", ":"]:
                    fileName = fileName.replace(char, "_")
                SeqIO.write(currentSequences, "$(runtime.outdir)/" + fileName, "fasta")
                currentSequences = []

        # write any remaining sequences
        if len(currentSequences) > 0:
            fileName = currentSequences[0].id + "_" + currentSequences[-1].id + ".fasta"
            for char in ["/", " ", ":"]:
                fileName = fileName.replace(char, "_")
            SeqIO.write(currentSequences, "$(runtime.outdir)/" + fileName, "fasta")