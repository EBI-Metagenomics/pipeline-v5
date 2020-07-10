#!/usr/bin/env python3

import argparse
import sys


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="change embl file")
    parser.add_argument("-i", "--input", dest="input", help="geneclusters.txt", required=True)
    parser.add_argument("-o", "--output", dest="output", help="filename for output", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        dict_names = {}
        with open(args.input, 'r') as table_file, open(args.output, 'w') as output_file:
            for line in table_file:
                line_list = line.strip().split('\t')
                name = line_list[0]
                ctg_pattern = line_list[3].split(';')[0].split('_')[0]
                line.replace(ctg_pattern, name)
                output_file.write(line.replace(ctg_pattern, name))


