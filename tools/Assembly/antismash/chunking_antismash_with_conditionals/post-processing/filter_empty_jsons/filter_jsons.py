#!/usr/bin/env python3

import argparse
import sys
import os
import json
from shutil import copy

OUTPUT_DIR = 'output'

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="change embl file")
    parser.add_argument("-j", "--jsons", dest="jsons", help="jsons ", required=True, nargs='+')

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        if not os.path.exists(OUTPUT_DIR): os.mkdir(OUTPUT_DIR)
        for input_file in args.jsons:
            with open(input_file, 'r') as json_file:
                cur_json = json.load(json_file)
                if cur_json != {}:
                    copy(input_file, OUTPUT_DIR)
