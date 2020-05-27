#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
import argparse


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Count lines in fastq")
    parser.add_argument("-f", "--input", dest="input", help="Input fastq", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        count = 0
        with open(args.input, 'r') as input_file, open('data.txt', 'w') as output_file:
            for line in input_file:
                count += 1
            output_file.write(str(int(count/4)))
