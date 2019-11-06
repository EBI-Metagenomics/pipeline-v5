import sys
import os
import cleaningUtils as cleaningUtils

__author__ = 'maxim'


class ChunkFASTAResultFileUtil:
    _rootDir = None    # protected variable

    _resultFileSuffix = None

    _targetSize = None

    _cutoff = None

    def __init__(self, infile, resultFileSuffix, targetSize, tool_path, outdir):
        self._infile = infile
        self._resultFileSuffix = resultFileSuffix
        self._targetSize = targetSize
        self._cutoff = float(targetSize)
        self._tool_path = tool_path
        self._outdir = outdir


    def chunkFASTAResultFile(self):
        print('Running the FASTA file chunking tool with the following settings:\ninfile: ' + self._infile + '\nresultFileSuffix:' + self._resultFileSuffix + '\ntargetSize:' + str(
            self._targetSize) + '\ncutoff:' + str(self._cutoff) + 'MB')
        # Check if that is a file we want to chunk
        # isValidFileName ?
        try:
            basename = os.path.basename(self._infile)
            absoluteFilePath = os.path.abspath(self._infile)
            dirpath = os.path.dirname(absoluteFilePath)
            outdirpath = self._outdir
            if cleaningUtils.checkIfAlreadyChunked(absoluteFilePath, 1):
                print("This file has already been chunked! End.")
            else:
                fileSizeInBytes = float(os.path.getsize(absoluteFilePath))
                fileSizeInMegabytes = fileSizeInBytes / 1024 / 1024
                print('Input file size in MB:', fileSizeInMegabytes)
                if fileSizeInMegabytes > self._cutoff:
                    print('Starting file chunking...')
                    cleaningUtils.splitfasta(absoluteFilePath, str(self._targetSize), self._tool_path)
                    print('File chunking finished.')
                    self.__moveChunkedFiles(dirpath, self._resultFileSuffix, self._infile, self._outdir)
                else:
                    print('The size of the file is below the cutoff (' + str(
                        fileSizeInMegabytes) + 'MB < ' + str(self._cutoff) + 'MB). No chunking necessary!')
                    if not os.path.exists(outdirpath):
                        os.makedirs(outdirpath)
                        print(outdirpath)
                    summaryOutput = open(os.path.join(outdirpath, os.path.basename(absoluteFilePath) + '.chunks'), "w")
                    summaryOutput.write(os.path.basename(absoluteFilePath) + '.gz')
                    summaryOutput.close()
        except:
            print("Unexpected error:", sys.exc_info()[0])
            raise

        print("FASTA file chunking tool finished.")


    def moveChunkedFiles(self, dir, prefix, summaryFilePath, outdir):
        print('Filtering for files with the following prefix:', prefix, 'and the following format: prefix.[num]')
        outdirpath = outdir
        try:
            chunkFileList = []
            for fileName in os.listdir(dir):
            #        Create chunk summary file if it does not exist
                if fileName.startswith(prefix) and len(prefix) < len(fileName) < len(
                    prefix) + 4 and not fileName.endswith(".gz"):
                    print('filtered out: ', fileName)
                    source = os.path.join(dir, fileName)
                    # Expected file name format: pCDS.fasta.1
                    # Convert to pCDS_1.fasta
                    splitResult = fileName.split('.')
                    if len(splitResult) != 3:
                        print("Unexpected string format:", fileName)
                        sys.exit(1)
                    newFileName = splitResult[0] + '_' + splitResult[2] + '.' + splitResult[1]
                    print('Created new file name:', newFileName)
                    newDestination = os.path.join(dir, newFileName)
                    os.rename(source, newDestination)
                    chunkFileList.append(newDestination)
            chunkFileList.sort()

            if not os.path.exists(outdirpath):
                os.makedirs(outdirpath)
                print('out dir:' + str(outdirpath))

            summaryOutput = open(os.path.join(outdirpath, os.path.basename(summaryFilePath) + '.chunks'), "w")
            for listItem in chunkFileList:
                head, tail = os.path.split(listItem)
                summaryOutput.write(tail + '.gz' + "\n")
                summaryOutput.flush()
                cleaningUtils.compress(filePath=listItem, tool='pigz', options=['-p', '16'])
                os.rename(listItem + '.gz', os.path.join(outdirpath, os.path.basename(listItem) + '.gz'))
            summaryOutput.close()
        except IOError as e:
            print("Could not write summary file" + summaryFilePath)
            print(e)
        except:
            print("Unexpected error:", sys.exc_info()[0])
            raise

    __moveChunkedFiles = moveChunkedFiles       # private copy of original method