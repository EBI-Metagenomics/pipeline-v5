#!/usr/bin/env python3

import argparse
import yaml

RAW_READS_ANALYSIS = "raw-reads"
ASSEMBLY_ANALYSIS = "assembly"
AMPLICON_ANALYSIS = "amplicon"


db_constants = ['ssu_db', 'lsu_db', ]
db_constant_strings = ['ssu_tax', 'lsu_tax', 'ssu_otus', 'lsu_otus', 'rfam_model_clans']


#   Append databases path to values in template yaml
def db_dir(db_path, yaml_path):
    if not db_path.endswith('/'):
        db_path += '/'
    with open(yaml_path) as f:
        doc = yaml.load(f, Loader=yaml.SafeLoader)
        for dc in db_constants:
            doc[dc]['path'] = db_path + doc[dc]['path']
        for dcs in db_constant_strings:
            doc[dcs] = db_path + doc[dcs]
        doc['rfam_models'] = [db_path + x for x in doc['rfam_models']]
    return doc


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Create the input.yml for the pipeline"
    )
    parser.add_argument(
        "-y", "--yml", dest="yml", help="YAML file with the constants", required=True
    )
    parser.add_argument(
        "-a",
        "--analysis",
        dest="analysis",
        choices=[RAW_READS_ANALYSIS, ASSEMBLY_ANALYSIS, AMPLICON_ANALYSIS],
        help="Type of analysis",
        required=True,
    )
    parser.add_argument(
        "-t",
        "--type",
        dest="type",
        choices=["single", "paired"],
        help="single/paired option",
        required=False,
    )
    parser.add_argument(
        "-f", "--fr", dest="fr", help="forward reads file path", required=False
    )
    parser.add_argument(
        "-r", "--rr", dest="rr", help="reverse reads file path", required=False
    )
    parser.add_argument(
        "-s", "--single", dest="single", help="single reads file path", required=False
    )
    parser.add_argument(
        "-o", "--output", dest="output", help="Output yaml file path", required=True
    )
    parser.add_argument(
        "-d", "--dbdir", dest="db_dir", help="Path to database directory", required=False
    )

    args = parser.parse_args()

    type_required = args.analysis in [RAW_READS_ANALYSIS, AMPLICON_ANALYSIS]
    if type_required and args.type is None:
        parser.error(
            f"For {RAW_READS_ANALYSIS} or {AMPLICON_ANALYSIS}, --type is required."
        )

    if args.analysis in [ASSEMBLY_ANALYSIS, AMPLICON_ANALYSIS] and args.single is None:
        parser.error(
            f"For {ASSEMBLY_ANALYSIS} or {AMPLICON_ANALYSIS}, --single is required."
        )

    print(f"Loading the constants from {args.yml}.")

    #load template yml file and append database path
    constants = db_dir(args.db_dir, args.yml)

    print("---------> prepare YML file for " + args.analysis)

    with open(args.output, "w") as output_yml:
        yaml.dump(constants, output_yml) #  write edited constants
        if args.analysis in [RAW_READS_ANALYSIS, AMPLICON_ANALYSIS]:
            if args.type == "single":
                print(
                    "single_reads:",
                    "  class: File",
                    "  format: edam:format_1930",
                    "  path: " + args.single,
                    sep="\n",
                    file=output_yml,
                )
            elif args.type == "paired":
                print(
                    "forward_reads:",
                    "  class: File",
                    "  format: edam:format_1930",
                    "  path: " + args.fr,
                    sep="\n",
                    file=output_yml,
                )
                print(
                    "reverse_reads:",
                    "  class: File",
                    "  format: edam:format_1930",
                    "  path: " + args.rr,
                    sep="\n",
                    file=output_yml,
                )
        elif args.analysis == ASSEMBLY_ANALYSIS:
            print(
                "contigs:",
                "  class: File",
                "  format: edam:format_1929",
                "  path: " + args.single,
                sep="\n",
                file=output_yml,
            )

        print("---------> yml done")