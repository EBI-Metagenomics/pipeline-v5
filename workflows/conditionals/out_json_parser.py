#!/usr/bin/env python3

import json
import argparse
import sys
import os


NAME_FILT_FASTA = 'filtered_fasta'
NAME_QC_STATUS = 'qc-status'
NAME_MOTUS = 'motus_input'


def parse_json(filename, yml, mode):
    if os.path.getsize(filename) == 0:
        sys.exit(3)
    else:
        with open(filename, 'r') as file_input:
            data = json.load(file_input)

        status = data[NAME_QC_STATUS]['basename']
        if status == 'QC-PASSED':
            print(' ! qc passed ! ')
            print('Add line to yml')
            location_fasta = data[NAME_FILT_FASTA]["location"].split('file://')[1]
            print('location fasta: ', location_fasta)
            fasta_filtered = '\n' + NAME_FILT_FASTA + ': \n' + '  path: ' + location_fasta + '\n  class: File'
            with open(yml, 'a') as yml_file:
                yml_file.write(fasta_filtered)
                if mode == 'raw-reads':
                    print('add motus_input')
                    location_motus_input = data[NAME_MOTUS]["location"].split('file://')[1]
                    motus_input = '\n' + NAME_MOTUS + ': \n' + '  path: ' + location_motus_input + '\n  class: File'
                    yml_file.write(motus_input)
            sys.exit(1)
        else:
            print(' ! qc failed !')
            sys.exit(2)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Parsing first sub-wf of pipeline")
    parser.add_argument("-j", "--json", dest="json", help="Output structure in json", required=True)
    parser.add_argument("-y", "--yml", dest="yml", help="Input Yml file", required=True)
    parser.add_argument("-m", "--mode", dest="mode", help="assembly/raw-reads/amplicon", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        print('Exit code == 1, if QC PASSED\nExit code == 2, if QC FAILED\nExit code == 3, if JSON EMPTY')
        parse_json(args.json, args.yml, args.mode)

