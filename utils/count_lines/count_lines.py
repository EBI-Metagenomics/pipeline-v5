#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import sys
import argparse
import os
import gzip


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Count lines in fastq")
    parser.add_argument("-f", "--input", dest="input", help="Input fastq", required=True)
    parser.add_argument("-n", "--number", dest="number", help="number to divide", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        count = 0
        with open('data.txt', 'w') as output_file:
            if '.gz' in os.path.basename(args.input):
                input_file = gzip.open(args.input, 'rb')
            else:
                input_file = open(args.input, 'r')
            for line in input_file:
                count += 1
            output_file.write(str(int(count/int(args.number))))
            input_file.close()
