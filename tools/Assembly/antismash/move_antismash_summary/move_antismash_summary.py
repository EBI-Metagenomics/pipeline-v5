#!/usr/bin/env python3

import argparse
import sys
import os
from shutil import copyfile

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="find multiple bgc hits in one line and separate")
    parser.add_argument("-a", "--antismash", dest="antismash", help="antismash gene clusters")
    parser.add_argument("-f", "--folder_name", dest="folder_name", help="tsv mapping gene clusters to full names", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()

        if not os.path.exists(args.folder_name):
           os.makedirs(args.folder_name)
        if args.antismash:
           copyfile(args.antismash, os.path.join(args.folder_name, os.path.basename(args.antismash)))

