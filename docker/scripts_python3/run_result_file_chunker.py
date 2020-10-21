#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright 2020 EMBL - European Bioinformatics Institute
#
# Licensed under the Apache License, Version 2.0 (the 'License');
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an 'AS IS' BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
import argparse
import logging
import os
from shutil import copyfile

from chunkTSVFileUtil import ChunkTSVFileUtil
from chunkFastaResultFileUtil import ChunkFASTAResultFileUtil

__author__ = 'Maxim Scheremetjew'


chunking_settings = {
    'TableChunkedFileLineNumber': 10000000,          # all tsv tables
    'TableUnchunkedFileSizeCutoffInMB': 2253,
    'chunkedFileSizeMaxInMB': 520,
    'chunkedFileSizeMinInMB': 480,
    'FaaFastaDefaultTargetSize': 1442,
    'FfnFastaDefaultTargetSize': 1980
}


def get_args():
    parser = argparse.ArgumentParser(
        description='Tool which chunks different types of pipeline result files (e.g. FASTA or TSV formatted)')
    parser.add_argument("-i", "--input", nargs='+', help="Input file which needs chunking", required=True)
    parser.add_argument("-f", "--format", choices=['fasta', 'tsv'], default='fasta', required=True)
    parser.add_argument("-t", "--type", choices=['p', 'n'], default='n', required=False)
    parser.add_argument("-c", "--cutoff", help="Set cutoff in Mb", required=False)
    parser.add_argument("-o", "--outdir", help="Output directory name", required=True)
    parser.add_argument("-v", "--verbose", action='store_true', required=False)
    return parser


def chunk_file(infile, file_format, fasta_type, outdir, basename, input_cutoff=None):
    if file_format == 'tsv':
        line_number = chunking_settings['TableChunkedFileLineNumber']
        cutoff = input_cutoff if input_cutoff else chunking_settings['TableUnchunkedFileSizeCutoffInMB']
        tsv_file_chunker = ChunkTSVFileUtil(infile=infile, line_number=line_number,
                                            cutoff=float(cutoff), outdir=outdir, basename=basename)
        tsv_file_chunker.chunk_tsv_result_file()
    elif file_format == 'fasta':
        if fasta_type == 'n':
            cutoff = input_cutoff if input_cutoff else chunking_settings["FfnFastaDefaultTargetSize"]
        else:
            cutoff = input_cutoff if input_cutoff else chunking_settings["FaaFastaDefaultTargetSize"]
        tool_path = 'gt'
        resultFileSuffix = os.path.basename(infile)
        fasta_file_chunker = ChunkFASTAResultFileUtil(infile=infile,
                                                      resultFileSuffix=resultFileSuffix,
                                                      targetSize=cutoff,
                                                      tool_path=tool_path,
                                                      outdir=outdir)
        fasta_file_chunker.chunkFASTAResultFile()
    else:
        logging.warning("Unsupported file type.")


if __name__ == "__main__":

    args = get_args().parse_args()
    for input_file in args.input:
        print('Processing', input_file)
        basename = os.path.basename(input_file)
        copy_input = os.path.join(os.path.dirname(os.path.abspath(input_file)), 'copy_' + basename)
        copyfile(input_file, copy_input)
        print('Copy input to ', copy_input)
        chunk_file(copy_input, args.format, args.type, args.outdir, basename, args.cutoff)
        print('Delete copy')
        os.remove(copy_input)