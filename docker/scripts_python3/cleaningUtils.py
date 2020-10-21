import os
import re
import subprocess
import sys
from Bio import SeqIO
import datetime
import time

__author__ = 'maxim'


def checkIfAlreadyChunked(path, delay=30):
    """Utility method that checks if a file or directory exists, accounting for NFS delays
           If there is a delay in appearing then the delay is logged
        """
    print("Checking for the '.chunks' file")
    startTime = datetime.datetime.today()
    while not os.path.exists(path):
        currentTime = datetime.datetime.today()
        timeSoFar = currentTime - startTime
        if timeSoFar.seconds > delay:
            return False
        time.sleep(1)
    return True


def split(path, lineNumber, prefix):
    try:
        print('--> run split')
        subprocess.check_output(['split', '-d', '-l', lineNumber, path, prefix], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as ex:
        print("--------error------")
        print(ex.cmd)
        print('return code', ex.returncode)
        print(ex.output)


def compress(filePath, tool, options):
    try:
        subprocess.check_output([tool] + options + [filePath], stderr=subprocess.STDOUT)
    except subprocess.CalledProcessError as ex:
        print("--------error------")
        print(ex.cmd)
        print('return code', ex.returncode)
        print(ex.output)


def moveChunkedFiles(dir, prefix, summaryFilePath, fileExtension):
    options = {'00': '1', '01': '2', '02': '3', '03': '4', '04': '5', '05': '6', '06': '7', '07': '8', '08': '9',
               '09': '10', '10': '11', '11': '12', '12': '13', '13': '14', '14': '15', '15': '16', '16': '17',
               '17': '18', '18': '19', '19': '20', '20': '21', '21': '22', '22': '23', '23': '24', '24': '25',
               '25': '26', '26': '27', '27': '28', '28': '29', '29': '30', '30': '31', '31': '32', '32': '33'}

    try:
        chunkFileList = []
        for fileName in os.listdir(dir):
            #        Create chunk summary file if is does not exist
            if fileName.startswith(prefix):
                source = os.path.join(dir, fileName)
                # Get the last 2 characters
                newSource = source.replace(source[-3:], '_' + options[source[-2:]])
                newDestination = newSource + '.' + fileExtension
                os.rename(source, newDestination)
                chunkFileList.append(newDestination)
        chunkFileList.sort()
        summaryOutput = open(summaryFilePath + '.chunks', "w")
        print(summaryOutput)
        for listItem in chunkFileList:
            head, tail = os.path.split(listItem)
            summaryOutput.write(tail + '.gz' + "\n")
            summaryOutput.flush()
        summaryOutput.close()
    except IOError as e:
        print("Could not write summary file: " + summaryFilePath)
        print(e)
    except:
        print("Unexpected error:", sys.exc_info()[0])
        raise
