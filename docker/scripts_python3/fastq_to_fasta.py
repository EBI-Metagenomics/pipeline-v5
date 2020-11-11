#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
    Simply Python script which converts a FASTQ file into a FASTA formatted file using BioPython.
"""

import sys
import argparse
from Bio import SeqIO


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert fastq to fasta")
    parser.add_argument("-i", "--input", dest="input", help="Input fastq file", required=True)
    parser.add_argument("-o", "--output", dest="output", help="Output fasta file", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        SeqIO.convert(args.input, "fastq", args.output, "fasta")