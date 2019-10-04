import sys
import os
import cleaningUtils as cleaningUtils

__author__ = 'maxim'


class ChunkFASTAResultFileUtil:
    _rootDir = None    # protected variable

    _resultFileSuffix = None

    _targetSize = None

    _cutoff = None

    def __init__(self, rootDir, resultFileSuffix, targetSize, tool_path):
        self._rootDir = rootDir
        self._resultFileSuffix = resultFileSuffix
        self._targetSize = targetSize
        self._cutoff = float(targetSize)
        self._tool_path = tool_path


    def chunkFASTAResultFile(self):
        print 'Running the FASTA file chunking tool with the following settings:\nrootDir: ' + self._rootDir + '\nresultFileSuffix:' + self._resultFileSuffix + '\ntargetSize:' + str(
            self._targetSize) + '\ncutoff:' + str(self._cutoff) + 'MB'
        for root, dirList, files in os.walk(self._rootDir):
            for fileName in files:
                # Check if that is a file we want to chunk
                if cleaningUtils.isValidFileName(fileName, self._resultFileSuffix):
                    try:
                        absoluteFilePath = os.path.join(root, fileName)
                        if cleaningUtils.checkIfAlreadyChunked(absoluteFilePath, 1):
                            print "This file has already been chunked! Jumping to the next file."
                        else:
                            fileSizeInBytes = float(os.path.getsize(absoluteFilePath))
                            fileSizeInMegabytes = fileSizeInBytes / 1024 / 1024
                            print 'Input file size in MB:',fileSizeInMegabytes
                            if fileSizeInMegabytes > self._cutoff:
                                print 'Starting file chunking...'
                                cleaningUtils.splitfasta(absoluteFilePath, str(self._targetSize), self._tool_path)
                                print 'File chunking finished.'
                                self.__moveChunkedFiles(root, fileName, absoluteFilePath)
                            else:
                                print 'The size of the file is below the cutoff (' + str(
                                    fileSizeInMegabytes) + 'MB < ' + str(self._cutoff) + 'MB). No chunking necessary!'
                                summaryOutput = open(absoluteFilePath + '.chunks', "w")
                                summaryOutput.write(fileName + '.gz')
                                summaryOutput.close()
                    except:
                        print "Unexpected error:", sys.exc_info()[0]
                        raise
                else:
                    pass
        print "FASTA file chunking tool finished."


    def moveChunkedFiles(self, dir, prefix, summaryFilePath):
        print 'Filtering for files with the following prefix:', prefix, 'and the following format: prefix.[num]'
        try:
            chunkFileList = []
            for fileName in os.listdir(dir):
            #        Create chunk summary file if it does not exist
                if fileName.startswith(prefix) and len(prefix) < len(fileName) < len(
                    prefix) + 4 and not fileName.endswith(".gz"):
                    print 'filtered out: ', fileName
                    source = os.path.join(dir, fileName)
                    # Expected file name format: pCDS.fasta.1
                    # Convert to pCDS_1.fasta
                    splitResult = fileName.split('.')
                    if len(splitResult) != 3:
                        print "Unexpected string format:", fileName
                        sys.exit(1)
                    newFileName = splitResult[0] + '_' + splitResult[2] + '.' + splitResult[1]
                    print 'Created new file name:', newFileName
                    newDestination = os.path.join(dir, newFileName)
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
            print "Could not write summary file" + summaryFilePath
            print e
        except:
            print "Unexpected error:", sys.exc_info()[0]
            raise

    __moveChunkedFiles = moveChunkedFiles       # private copy of original method