#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
    Simply Python script that returns table in CSV format.
"""

import sys
import argparse


def convert_table(table, outputname):
    with open(table, 'r') as file_in, open(outputname, 'w') as file_out:
        for line in file_in:
            line = line.strip().split('\t')
            output_line = '"' + '","'.join(line) + '"\n'
            file_out.write(output_line)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert table to CSV")
    parser.add_argument("-i", "--input", dest="input", help="Input table", required=True)
    parser.add_argument("-o", "--output", dest="output", help="Output filename", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        convert_table(args.input, args.output)