#!/usr/bin/env python2
# -*- coding: utf-8 -*-

"""
    Simply Python script which converts a FASTQ file into a FASTA formatted file using BioPython.
"""

import sys
from Bio import SeqIO


def main():
    SeqIO.convert(sys.stdin, "fastq", sys.stdout, "fasta")


if __name__ == "__main__":
    main()
