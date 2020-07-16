#!/usr/bin/env python3

import argparse
import sys
import json

NAME_LIMIT = 16

if __name__ == "__main__":

    parser = argparse.ArgumentParser(description="change embl file")
    parser.add_argument("-i", "--input", dest="input", help="geneclusters.js", required=True)
    parser.add_argument("-o", "--output", dest="output", help="filename for output", required=True)
    parser.add_argument("-a", "--accession", dest="accession", help="accession of run: ERZ***_FASTA", required=True)

    if len(sys.argv) == 1:
        parser.print_help()
    else:
        args = parser.parse_args()
        accession = args.accession.split('_')[0]

        with open(args.input, 'r') as jsfile, open(args.output, 'w') as out_json:
            data = json.load(jsfile)
            for cluster in data:
                for locus in data[cluster]['orfs']:
                    old_locus_tag = locus['locus_tag']
                    if len(old_locus_tag.split('_')[0].split('ctg')) > 1:
                        number = old_locus_tag.split('_')[0].split('ctg')[1]
                        postfix = old_locus_tag.split('_')[1]

                        limit = min(NAME_LIMIT - 1 - len(number), len(accession) - 1)
                        name = accession[0:limit]

                        new_locus_tag = name + '-' + number + '_' + postfix
                        locus['locus_tag'] = new_locus_tag
                        description = locus['description']
                        locus['description'] = description.replace(old_locus_tag, new_locus_tag)
            json.dump(data, out_json)

