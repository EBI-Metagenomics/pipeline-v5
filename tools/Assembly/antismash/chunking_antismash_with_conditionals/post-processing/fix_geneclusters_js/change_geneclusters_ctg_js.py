#!/usr/bin /hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda3-4.6.14/bin/python3


import argparse
import sys
import json

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="change embl file")
    parser.add_argument("-i", "--input", dest="input", help="geneclusters.js", required=True)
    parser.add_argument("-o", "--output", dest="output", help="filename for output", required=True)
    parser.add_argument("-a", "--accession", dest="accession", help="accession of run: ERZ***_FASTA", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        name = args.accession.split('_')[0]
        with open(args.input, 'r') as jsfile, open(args.output, 'w') as out_json:
            data = json.load(jsfile)
            for cluster in data:
                for locus in data[cluster]['orfs']:
                    old_locus_tag = locus['locus_tag']
                    number = old_locus_tag.split('_')[0].split('ctg')[1]
                    postfix = old_locus_tag.split('_')[1]
                    new_locus_tag = name + '-' + number + '_' + postfix
                    locus['locus_tag'] = new_locus_tag
                    description = locus['description']
                    locus['description'] = description.replace(old_locus_tag, new_locus_tag)
            json.dump(data, out_json)

