#!/usr/bin/env python3
import hashlib
import sys
import argparse
import os


def file_as_bytes(file):
    with file:
        return file.read()

def get_digest(file_path):
    hash_sha1 = hashlib.sha1()
    with open(file_path, 'rb') as file:
        while True:
            chunk = file.read(hash_sha1.block_size)
            if not chunk:
                break
            hash_sha1.update(chunk)
    return hash_sha1.hexdigest()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Generate sha1 checksum of file")
    parser.add_argument("-i", "--input", dest="input", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        output_name = os.path.basename(args.input) + '.sha1'
        with open(output_name, 'w') as file_out:
            # md5sum
            #md5sum = hashlib.md5(file_as_bytes(open(file_in, 'rb'))).hexdigest()

            # reading whole file approach
            # sha1sum = hashlib.sha1(file_as_bytes(open(args.input, 'rb'))).hexdigest()

            # reading by chunks approach
            sha1sum = get_digest(args.input)
            file_out.write('  '.join([sha1sum, os.path.basename(args.input)]) + '\n')
