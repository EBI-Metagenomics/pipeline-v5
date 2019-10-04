#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Copyright 2019 EMBL - European Bioinformatics Institute
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
import sys

from chunkTSVFileUtil import ChunkTSVFileUtil

__author__ = 'Maxim Scheremetjew'

"""
    [ResultFiles]
    i5ChunkedFileLineNumber = 10000000
    i5UnchunkedFileSizeCutoffInMB = 2253
    chunkedFileSizeMaxInMB = 520
    chunkedFileSizeMinInMB = 480
    interproscanFastaDefaultTargetSize = 1819
    pCDSFastaDefaultTargetSize = 1847
    noFunctionFastaDefaultTargetSize = 1853
    nucleotideReadsFastaDefaultTargetSize = 1980
    cdsFaaDefaultTargetSize = 1350
    cdsUnannotatedFaaDefaultTargetSize = 1442
    cdsUnannotatedFfnDefaultTargetSize = 1980
    cdsAnnotatedFaaDefaultTargetSize = 1442
    cdsAnnotatedFfnDefaultTargetSize = 1980
"""

chunking_settings = {
    'i5ChunkedFileLineNumber': 10000000,
    'i5UnchunkedFileSizeCutoffInMB': 2253,
    'chunkedFileSizeMaxInMB': 520,
    'chunkedFileSizeMinInMB': 480,
    'interproscanFastaDefaultTargetSize': 1819,
    'pCDSFastaDefaultTargetSize': 1847,
}


def parse_args(argv):
    parser = argparse.ArgumentParser(
        description='Tool which chunks different types of pipeline result files (e.g. FASTA or TSV formatted)')
    parser.add_argument('infile', help="Input file which needs chunking.")
    parser.add_argument('file-type', choices=['fasta', 'tsv'], default='fasta')
    parser.add_argument('--compression-level', choices=['fasta', 'tsv'], default='fasta')
    parser.add_argument('-v', '--verbose', action='store_true')
    return parser.parse_args(argv)


def chunk_tsv_file(analysisDirectory, interProScanOutputFileName, compression_level):
    line_number = chunking_settings['i5ChunkedFileLineNumber']
    cutoff = chunking_settings['i5UnchunkedFileSizeCutoffInMB']
    tsv_file_chunker = ChunkTSVFileUtil(analysisDirectory, '_I5.tsv', line_number, float(cutoff))
    tsv_file_chunker.chunk_tsv_result_file()

    #   Perform compression of the InterProScan chunk files
    #   1. Parse the InterProScan '.chunks' file to get the chunks
    #   2. Iterate over the chunk files and compress them
    #   3. Delete chunks at the end

    #   Load chunk file names into a list
    chunkFilePath = interProScanOutputFileName + '.chunks'
    print
    "Parsing the InterProScan chunk file located at: \n" + chunkFilePath
    #   Load chunk file names into a list
    #   Check first of all if file path exists
    if checkFilePath(chunkFilePath):
        chunkFile = putil.fileOpen(chunkFilePath, "r")
        chunkFileNames = []
        for line in chunkFile:
            chunkFileNames.append(line.replace('.gz', '').rstrip("\r\n"))
        chunkFile.close()

        #   Iterate over the list of chunk files and run compression
        #   Delete the chunk file when finished
        for chunkFileName in chunkFileNames:
            chunkFileFilePathAbsolute = os.path.join(analysisDirectory, chunkFileName)
            runFileCompressionAndDelete(chunkFileFilePathAbsolute, compressionLevel)
    else:
        print
        "Chunked file does not exist. Skipping the compression step..."


def chunk_file(infile, file_type, compress_level):
    # TODO: Implement
    if file_type == 'tsv':
        chunk_tsv_file(output_path, interProScanOutputFileName,
                       chunking_settings['i5UnchunkedFileSizeCutoffInMB'],
                       compress_level)


def main(argv=sys.argv[1:]):
    args = parse_args(argv)
    logging.basicConfig(level=logging.DEBUG if args.verbose else logging.INFO)
    infile = args['infile']
    file_type = args['file_type']
    default_compress_level = args['compression_level']

    chunk_file(infile, file_type, default_compress_level)


if __name__ == '__main__':
    main()
