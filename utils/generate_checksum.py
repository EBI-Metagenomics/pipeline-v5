#!/usr/bin/env python3
import hashlib
import sys
import argparse
import os


def file_as_bytes(file):
    with file:
        return file.read()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Convert table to CSV")
    parser.add_argument("-i", "--input", dest="input", nargs='+', required=True)
    parser.add_argument("-o", "--output", dest="output", help="Output filename", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        with open(args.output, 'w') as file_out:
            file_out.write('\t'.join(['basename', 'HashSum']) + '\n')
            for file_in in args.input:
                #md5sum = hashlib.md5(file_as_bytes(open(file_in, 'rb'))).hexdigest()
                sha1sum = hashlib.sha1(file_as_bytes(open(file_in, 'rb'))).hexdigest()
                file_out.write('\t'.join([os.path.basename(file_in), sha1sum]) + '\n')
