#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
    Simply Python script that returns table in CSV format.
"""

import sys
import argparse


def convert_table(table, outputname):
    num = 0
    with open(table, 'r') as file_in, open(outputname, 'w') as file_out:
        for line in file_in:
            line = line.strip().split('\t')
            if num == 0:
                columns_num = len(line)
            if len(line) != columns_num:
                additional = ',' + ','.join(['""' for _ in range(columns_num-len(line))])
            else:
                additional = ''
            output_line = '"' + '","'.join(line) + '"' + additional + '\n'
            file_out.write(output_line)
            num += 1


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert table to CSV")
    parser.add_argument("-i", "--input", dest="input", help="Input table", required=True)
    parser.add_argument("-o", "--output", dest="output", help="Output filename", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        convert_table(args.input, args.output)