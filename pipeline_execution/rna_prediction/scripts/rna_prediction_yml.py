#!/usr/bin/env python3

import argparse
from ruamel.yaml import YAML
import os

RAW_READS_ANALYSIS = "raw-reads"
ASSEMBLY_ANALYSIS = "assembly"
AMPLICON_ANALYSIS = "amplicon"


db_fields = [
    "ssu_db",
    "lsu_db",
    "ssu_tax",
    "lsu_tax",
    "ssu_otus",
    "lsu_otus",
    "rfam_models",
    "rfam_model_clans",
]


def db_dir(db_path, yaml_path):
    """Append databases path to values in template yaml"""
    if not db_path.endswith("/"):
        db_path += "/"
    with open(yaml_path) as f:
        yaml = YAML(typ="safe")
        doc = yaml.load(f)
        for db_field in db_fields:
            if isinstance(doc[db_field], (list, tuple)):
                for el in doc[db_field]:
                    el["path"] = os.path.join(db_path, el["path"])
            else:
                doc[db_field]["path"] = os.path.join(db_path, doc[db_field]["path"])
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
        "-d",
        "--dbdir",
        dest="db_dir",
        help="Path to database directory",
        required=False,
    )

    args = parser.parse_args()

    type_required = args.analysis in [RAW_READS_ANALYSIS, AMPLICON_ANALYSIS]
    if type_required and not args.type:
        parser.error(
            f"For {RAW_READS_ANALYSIS} or {AMPLICON_ANALYSIS}, --type is required."
        )

    if args.analysis in [ASSEMBLY_ANALYSIS, AMPLICON_ANALYSIS] and not args.single:
        parser.error(
            f"For {ASSEMBLY_ANALYSIS} or {AMPLICON_ANALYSIS}, --single is required."
        )

    print(f"Loading the constants from {args.yml}.")

    # load template yml file and append database path
    template_yml = db_dir(args.db_dir, args.yml)

    print("---------> prepare YML file for " + args.analysis)

    with open(args.output, "w") as output_yml:
        yaml = YAML(typ="safe")
        if args.analysis in [RAW_READS_ANALYSIS, AMPLICON_ANALYSIS]:
            if args.type == "single":
                template_yml["single_reads"] = {
                    "class": "File",
                    "format": "edam:format_1930",
                    "path": args.single,
                }
            elif args.type == "paired":
                template_yml["forward_reads"] = {
                    "class": "File",
                    "format": "edam:format_1930",
                    "path": args.fr,
                }
                template_yml["reverse_reads"] = {
                    "class": "File",
                    "format": "edam:format_1930",
                    "path": args.rr,
                }
        elif args.analysis == ASSEMBLY_ANALYSIS:
            template_yml["contigs"] = {
                "class": "File",
                "format": "edam:format_1929",
                "path": args.single,
            }
        yaml.dump(template_yml, output_yml)

        print("---------> yml done")
