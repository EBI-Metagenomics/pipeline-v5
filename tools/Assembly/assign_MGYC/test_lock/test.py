#!/usr/bin/env python3

from oslo_concurrency import lockutils
import os
import argparse

def get_args():
    parser = argparse.ArgumentParser(description="create file with MGYCs for run")
    parser.add_argument('-n', '--number', dest='number', required=True, help='number')
    return parser

args = get_args().parse_args()

path_test = "/hps/nobackup2/production/metagenomics/pipeline/testing/kate/oslo"

with lockutils.lock('external', 'test-', lock_path=path_test, external=True):
    # Open some files we can use for locking
    filename = 'test.txt'
    fd = open(filename, 'r+')

    # try locking the file without blocking. If the lock fails
    # we get an IOError and bail out with bad exit code
    count = 0
    try:
        max = fd.read()
        print('Start with accession number ', max)
        next_acc = int(max) + int(args.number)
        print('Finish with accession number ', next_acc, 'number', args.number)
        fd.seek(0)
        fd.truncate()
        fd.write(str(next_acc))
    except IOError:
        os._exit(2)
    finally:
        fd.close()