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
    parser.add_argument("-i", "--input", dest="input", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        output_name = os.path.basename(args.input) + '.sha1'
        with open(output_name, 'w') as file_out:
            #md5sum = hashlib.md5(file_as_bytes(open(file_in, 'rb'))).hexdigest()
            sha1sum = hashlib.sha1(file_as_bytes(open(args.input, 'rb'))).hexdigest()
            file_out.write('  '.join([sha1sum, os.path.basename(args.input)]) + '\n')
