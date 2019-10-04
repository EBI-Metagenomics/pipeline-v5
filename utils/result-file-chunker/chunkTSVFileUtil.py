import sys
import os
import re
import cleaningUtils as cleaningUtils
import logging

__author__ = 'maxim'


class ChunkTSVFileUtil:
    _rootDir = None  # protected variable

    _resultFileSuffix = None

    _lineNumber = None

    _cutoff = None  # type float

    def __init__(self, rootDir, resultFileSuffix, lineNumber, cutoff):
        self._rootDir = rootDir
        self._resultFileSuffix = resultFileSuffix
        self._lineNumber = str(lineNumber)
        self._cutoff = cutoff

    def chunk_tsv_result_file(self):
        logging.info(
            'Running the chunking program with the following settings:\nrootDir: {}\nresultFileSuffix: {}\nlineNumber: {}\ncutoff: {} MB'.format(
                self._rootDir, self._resultFileSuffix, self._lineNumber, self._cutoff))
        for root, dirList, files in os.walk(self._rootDir):
            for fileName in files:
                # Check if that is a file we want to chunk
                if cleaningUtils.isValidFileName(fileName, self._resultFileSuffix):
                    try:
                        absoluteFilePath = os.path.join(root, fileName)
                        if cleaningUtils.checkIfAlreadyChunked(absoluteFilePath, 1):
                            print("This file has already been chunked! Jumping to the next file.")
                        else:
                            fileSizeInBytes = float(os.path.getsize(absoluteFilePath))
                            fileSizeInMegabytes = fileSizeInBytes / 1024 / 1024
                            if fileSizeInMegabytes > self._cutoff:
                                prefix = re.sub('\.tsv$', '', fileName) + '_'
                                #    split -d -l 10000000 ERR599112_MERGED_FASTQ_I5.tsv ERR599112_MERGED_FASTQ_I5_
                                cleaningUtils.split(absoluteFilePath, self._lineNumber, os.path.join(root, prefix))
                                self.__moveChunkedFiles(root, prefix, absoluteFilePath)
                            else:
                                print(
                                    'The size of the file is below the cutoff ( {} MB < {} MB). No chunking necessary!'.format(
                                        str(fileSizeInMegabytes), self._cutoff))
                                summaryOutput = open(absoluteFilePath + '.chunks', "w")
                                summaryOutput.write(fileName + '.gz')
                                summaryOutput.close()
                    except:
                        raise
                else:
                    pass

    def moveChunkedFiles(self, dir, prefix, summaryFilePath):
        options = {'00': '1', '01': '2', '02': '3', '03': '4', '04': '5', '05': '6', '06': '7', '07': '8', '08': '9',
                   '09': '10', '10': '11', '11': '12', '12': '13', '13': '14', '14': '15', '15': '16', '16': '17',
                   '17': '18', '18': '19', '19': '20', '20': '21', '21': '22', '22': '23', '23': '24', '24': '25',
                   '25': '26', '26': '27', '27': '28', '28': '29', '29': '30', '30': '31', '31': '32', '32': '33'}

        try:
            chunkFileList = []
            for fileName in os.listdir(dir):
                #        Create chunk summary file if is does not exist
                if fileName.startswith(prefix) and not fileName.endswith(".tsv"):
                    source = os.path.join(dir, fileName)
                    # print source
                    # print "-3:" + source[-3:]
                    # print "-2:" + source[-2:]
                    # print "Option return:" + options[source[-2:]]
                    # Get the last 2 characters
                    newSource = source.replace(source[-3:], '_' + options[source[-2:]])
                    newDestination = newSource + '.tsv'
                    os.rename(source, newDestination)
                    chunkFileList.append(newDestination)
            chunkFileList.sort()
            summaryOutput = open(summaryFilePath + '.chunks', "w")
            for listItem in chunkFileList:
                head, tail = os.path.split(listItem)
                summaryOutput.write(tail + '.gz' + "\n")
                summaryOutput.flush()
            summaryOutput.close()
        except IOError as e:
            print
            "Could not write summary file" + summaryFilePath
            print
            e
        except:
            print
            "Unexpected error:", sys.exc_info()[0]
            raise

    __moveChunkedFiles = moveChunkedFiles  # private copy of original method
