#!/usr/bin/env python

import argparse
import os

os.mkdir('contigs')

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Separation interposca result by contigs')
    parser.add_argument('-i', dest='input', help='InteproScan tsv results', required=True)
    args = parser.parse_args()

    contigs = {}
    with open(args.input, 'r') as file_in:
        for line in file_in:
            line = line.strip().split('\t')
            if line[0] not in contigs:
                contigs[line[0]] = []
            contigs[line[0]].append('\t'.join(line))

    for key in contigs:
        for line in contigs[key]:
            with open('contigs/' + key, 'w') as file_out:
                file_out.write(line)
        file_out.close()
