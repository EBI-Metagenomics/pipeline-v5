#!/usr/bin/env python3

import json
import argparse
import sys


NAME_FILT_FASTA = 'filtered_fasta'
NAME_QC_STATUS = 'qc-status'


def parse_json(filename, yml):
    with open(filename, 'r') as file_input:
        data = json.load(file_input)

    status = data[NAME_QC_STATUS]['basename']
    if status == 'QC-PASSED':
        print(' ! qc passed ! ')
        print('Add line to yml')
        location_fasta = data[NAME_FILT_FASTA]["location"].split('file://')[1]
        print('location fasta: ', location_fasta)
        fasta_filtered = '\nfiltered_fasta: \n' + '  path: ' + location_fasta + '\n  class: File'
        with open(yml, 'a') as yml_file:
            yml_file.write(fasta_filtered)
        sys.exit(1)
    else:
        print(' ! qc failed !')
        sys.exit(2)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Parsing first sub-wf of pipeline")
    parser.add_argument("-j", "--json", dest="json", help="Output structure in json", required=True)
    parser.add_argument("-y", "--yml", dest="yml", help="Input Yml file", required=True)


    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        print('Exit code == 1, if QC PASSED\nExit code == 2, if QC FAILED')
        parse_json(args.json, args.yml)


