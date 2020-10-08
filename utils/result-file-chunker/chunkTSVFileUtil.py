import sys
import os
import re
import cleaningUtils as cleaningUtils
import logging
import shutil

__author__ = 'maxim'


class ChunkTSVFileUtil:

    def __init__(self, infile, line_number, cutoff, outdir):
        """

        :param infile:
        :param line_number:
        :param cutoff: file size cutoff in MB for chunking.
        :type cutoff: float
        """
        self._infile = infile
        self._line_number = str(line_number)
        self._cutoff = cutoff
        self._outdir = outdir


    def print_setup(self):
        print(vars(self))
        # logging.info(
        #     'Running the chunking program with the following settings:\nrootDir: {}\nresultFileSuffix: {}\nlineNumber: {}\ncutoff: {} MB'.format(
        #         self._rootDir, self._resultFileSuffix, self._lineNumber, self._cutoff))


    def chunk_tsv_result_file(self):
        self.print_setup()
        basename = os.path.basename(self._infile)
        nameroot = os.path.splitext(basename)[0]
        abspath = os.path.abspath(self._infile)
        dirpath = os.path.dirname(abspath)
        outdirpath = self._outdir
        try:
            if cleaningUtils.checkIfAlreadyChunked(os.path.join(outdirpath, os.path.basename(self._infile)), 1):
                logging.info("This file has already been chunked! Jumping to the next file.")
            else:
                print("File has not already chunked")
                infile_size_bytes = float(os.path.getsize(self._infile))
                infile_size_megabytes = infile_size_bytes / 1024 / 1024
                if infile_size_megabytes > self._cutoff:
                    prefix = nameroot + '_'
                    print('prefix: ' + prefix)
                    #    split -d -l 10000000 ERR599112_MERGED_FASTQ_I5.tsv ERR599112_MERGED_FASTQ_I5_
                    cleaningUtils.split(self._infile, self._line_number, os.path.join(dirpath, prefix))
                    print('split step done. Running moveChunkedFiles')
                    self.__moveChunkedFiles(dirpath, prefix, self._infile, self._outdir)
                else:
                    print('The size of the file is below the cutoff ( {} MB < {} MB). No chunking necessary!'.format(
                        str(infile_size_megabytes), self._cutoff))

                    if not os.path.exists(outdirpath):
                        os.makedirs(outdirpath)
                        print(outdirpath)

                    # move and gzip initial file
                    shutil.copyfile(self._infile, os.path.join(outdirpath, os.path.basename(self._infile)))
                    cleaningUtils.compress(filePath=os.path.join(outdirpath, os.path.basename(self._infile)),
                                           tool='pigz', options=['-p', '16'])

                    with open(os.path.join(outdirpath, os.path.basename(self._infile) + '.chunks'), "w") as f:
                        f.write(basename + '.gz')
        except:
            raise

    def move_chunked_files(self, dir, prefix, summaryFilePath, outdir):
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

            outdirpath = outdir  # os.path.join(dir, outdir)
            if not os.path.exists(outdirpath):
                os.makedirs(outdirpath)
                print('out dir:' + str(outdirpath))

            newSummaryFilePath = os.path.join(outdirpath, os.path.basename(summaryFilePath) + '.chunks')
            with open(newSummaryFilePath, "w") as f:
                for listItem in chunkFileList:
                    head, tail = os.path.split(listItem)
                    f.write(tail + '.gz' + "\n")
                    f.flush()
                    cleaningUtils.compress(filePath=listItem, tool='pigz', options=['-p', '16'])
                    os.rename(listItem+'.gz', os.path.join(outdirpath, os.path.basename(listItem)+'.gz'))
        except IOError as e:
            print("Could not write summary file: " + newSummaryFilePath)
            print(e)
        except:
            print("Unexpected error:", sys.exc_info()[0])
            raise

    __moveChunkedFiles = move_chunked_files  # private copy of original method
