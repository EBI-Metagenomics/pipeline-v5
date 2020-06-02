#!/usr/bin/env /hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda3-4.6.14/bin/python3
# -*- coding: utf-8 -*-

import sys
import argparse


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Count lines in fastq")
    parser.add_argument("-f", "--input", dest="input", help="Input fastq", required=True)
    parser.add_argument("-n", "--number", dest="number", help="number to divide", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        count = 0
        with open(args.input, 'r') as input_file, open('data.txt', 'w') as output_file:
            for line in input_file:
                count += 1
            output_file.write(str(int(count/int(args.number))))
