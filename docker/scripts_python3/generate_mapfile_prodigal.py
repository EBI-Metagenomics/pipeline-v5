#!/usr/bin/env python3

import argparse
import csv
import hashlib
from Bio import SeqIO


def create_digest(seq):
    digest = hashlib.sha256(str(seq).encode('utf-8')).hexdigest()
    return digest


def generate(args):
    print("Generating...")
    with open(args.output, "w") as map_tsv:
        tsv_map = csv.writer(map_tsv, delimiter="\t")
        tsv_map.writerow(["digest", "name"])
        for record in SeqIO.parse(args.input, "fasta"):
            digest = create_digest(record.seq)
            tsv_map.writerow([digest, record.description])
    print("Done")


def main():
    """Generator of maps between sequence sha128 digest and header (MGYP)"""
    parser = argparse.ArgumentParser(
        description="Genarate mapfile")
    parser.add_argument(
        "-i", "--input", help="indicate input FASTA file", required=True)
    parser.add_argument(
        "-o", "--output", help="indicate output MAP file", required=True)
    args = parser.parse_args()
    generate(args)


if __name__ == "__main__":
    main()