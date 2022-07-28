#!/usr/bin/env python

# Copyright 2021 EMBL - European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import argparse
import os
import shutil
import sys
from pathlib import Path
from stat import S_IREAD, S_IWUSR, S_IWGRP, S_IRGRP, S_IEXEC, S_IXGRP

FILE_EXTENSIONS = [".py", ".sh", ".json", ".pl", ".obo", ".txt", ".jar", ".vmoptions"]

IGNORE_EXTENSIONS = [
    ".cwl",
]

IGNORE_LIST = [
    "__init__.py",
    "__init__",
    "copy_utils.py",
]

# binaries or scripts with no extension
SPECIFIC_FILES = [
    "add_header",
    "awk_tool",
    "owltools",
    "faselector",
    "format_bedfile",
]

if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        "Collect the scripts used on the pipeline in a single folder (needed on ebi-cluster)."
    )
    parser.add_argument(
        "-p",
        "--pipeline",
        required=True,
        action="store",
        dest="pipeline_folder",
        help="Pipeline repo base folder",
    )
    parser.add_argument(
        "-o",
        "--ouput",
        required=True,
        action="store",
        dest="output_folder",
        help="Output destination folder",
    )

    args = parser.parse_args()

    for dirpath, _, files in os.walk(args.pipeline_folder):
        for file_ in files:
            pfile = Path(file_)
            file_name = pfile.stem
            file_extension = pfile.suffix

            if file_name in IGNORE_LIST or file_extension in IGNORE_EXTENSIONS:
                continue

            output_file = f"{file_name}{file_extension}"
            if not file_extension:
                output_file = file_name

            if file_name in SPECIFIC_FILES or file_extension in FILE_EXTENSIONS:
                dest = os.path.join(args.output_folder, output_file)
                file_path = os.path.join(dirpath, file_)

                if os.path.islink(file_path):
                    continue

                shutil.copy(file_path, dest)
                print(f"Script {file_path} copied to {dest}")
                os.chmod(dest, S_IREAD | S_IRGRP | S_IWUSR | S_IRGRP | S_IEXEC)
                print(f"- made {dest} as writable")
