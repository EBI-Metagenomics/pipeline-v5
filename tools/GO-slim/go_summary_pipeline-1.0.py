#!/usr/bin/env python2

"""
INPUT - InterProScan result file:
ERR164409.102041_1_142_-	eb53bcbf0748558f1f6c087ad5c76bcb	46	Gene3D	G3DSA:3.90.1150.10		2	43	9.5E-6	T	18-02-2015	IPR015422	Pyridoxal phosphate-dependent transferase, major region, subdomain 2	GO:0003824|GO:0030170
ERR164409.101777_1_384_-	61af698732af6657579decd4ae9174b4	127	Pfam	PF00483	Nucleotidyl transferase	1	122	9.5E-31	T	18-02-2015	IPR005835	Nucleotidyl transferase	GO:0009058|GO:0016779	Reactome: REACT_17015
OUTPUT:
Full GO summary file output:
"GO:0055114","oxidation-reduction process","biological_process","8997"
"GO:0008152","metabolic process","biological_process","6400"
GO slim summary file output:
"GO:0030031","cell projection assembly","biological_process","0"
"GO:0071554","cell wall organization or biogenesis","biological_process","12"
"""
import argparse
import json
import os
import subprocess
import sys
import datetime
import time
import re
import collections
import io
import psutil as psutil

__author__ = 'Maxim Scheremetjew EMBL-EBI'

req_version = (2, 7)
cur_version = sys.version_info
if cur_version < req_version:
    print "Your Python interpreter is too old. You need version 2.7.x"  # needed for argparse
    sys.exit()


class GOSummaryUtils(object):
    @classmethod
    def __pathExists(self, path, delay=30):
        """Utility method that checks if a file or directory exists, accounting for NFS delays
           If there is a delay in appearing then the delay is logged
        """
        startTime = datetime.datetime.today()
        while not os.path.exists(path):
            currentTime = datetime.datetime.today()
            timeSoFar = currentTime - startTime
            if timeSoFar.seconds > delay:
                return False
            time.sleep(1)
        endTime = datetime.datetime.today()
        totalTime = endTime - startTime
        # if totalTime.seconds > 1:
        #    print "Pathop: Took", totalTime.seconds, "to determine that path ",path, "exists"
        return True

    @classmethod
    def __fileOpen(self, fileName, fileMode, buffer=0):
        """File opening utility that accounts for NFS delays
           Logs how long each file-opening attempt takes
           fileMode should be 'r' or 'w'
        """
        startTime = datetime.datetime.today()
        # print "Fileop: Trying to open file", fileName,"in mode", fileMode, "at", startTime.isoformat()
        if fileMode == 'w' or fileMode == 'wb':
            fileHandle = open(fileName, fileMode)
            fileHandle.close()
        while not os.path.exists(fileName):
            currentTime = datetime.datetime.today()
            timeSoFar = currentTime - startTime
            if timeSoFar.seconds > 30:
                print "Fileop: Took more than 30s to try and open", fileName
                print "Exiting"
                sys.exit(1)
            time.sleep(1)
        try:
            fileHandle = open(fileName, fileMode, buffer)
        except IOError as e:
            print "I/O error writing file{0}({1}): {2}".format(fileName, e.errno, e.strerror)
            print "Exiting"
            sys.exit(1)
        endTime = datetime.datetime.today()
        totalTime = endTime - startTime
        # print "Fileop: Opened file", fileName, "in mode", fileMode, "in", totalTime.seconds, "seconds"
        return fileHandle

    @classmethod
    def __goSortKey(self, item):
        return (item[2], - item[3])

    @staticmethod
    def getFullGOSummary(core_gene_ontology, go2protein_count_dict, topLevelGoIds):
        summary = []

        for goId, term, category in core_gene_ontology:

            if (goId in go2protein_count_dict) and (
                        goId not in topLevelGoIds):  # make sure that top level terms are not included (they tell you nothing!)
                count = go2protein_count_dict.get(goId)
                summary.append((goId, term, category, count))
        summary.sort(key=GOSummaryUtils.__goSortKey)
        return summary

    @staticmethod
    def get_go_slim_summary(go_slim_banding_file, go_slims_2_protein_count):
        summary = []

        file_handler = GOSummaryUtils.__fileOpen(go_slim_banding_file, "r")

        for line in file_handler:
            if line.startswith("GO"):
                line = line.strip()
                line_chunks = line.split("\t")
                go_id = line_chunks[0]
                term = line_chunks[1]
                category = line_chunks[2]
                # Default value for the count
                count = 0
                if go_id in go_slims_2_protein_count:
                    count = go_slims_2_protein_count.get(go_id)
                summary.append((go_id, term, category, count))
        return summary

    @staticmethod
    def get_gene_ontology(obo_file):
        """
        Parses OBO formatted file.
        :param obo_file:
        :return:
        """
        result = []
        handle = GOSummaryUtils.__fileOpen(obo_file, "r")
        id, term, category = "", "", ""
        for line in handle:
            line = line.strip()
            splitLine = line.split(": ")
            if line.startswith("id:"):
                id = splitLine[1].strip()
            elif line.startswith("name:"):
                term = splitLine[1].strip()
            elif line.startswith("namespace"):
                category = splitLine[1].strip()
            else:
                if id.startswith("GO:") and id and term and category:
                    item = (id, term, category)
                    result.append(item)
                    id, term, category = "", "", ""
        handle.close()
        return result

    @staticmethod
    def parseIprScanOutput(iprscanOutput):
        # namedtuple type definition
        ParsingStats = collections.namedtuple('ParsingStats',
                                              'num_of_lines num_of_proteins proteins_with_go num_of_unique_go_ids')
        go2protein_count = {}
        num_of_proteins_with_go = 0
        total_num_of_proteins = 0
        if GOSummaryUtils.__pathExists(iprscanOutput):
            handle = GOSummaryUtils.__fileOpen(iprscanOutput, "r")
            goPattern = re.compile("GO:\d+")
            line_counter = 0
            previous_protein_acc = None
            go_annotations_single_protein = set()
            for line in handle:
                line_counter += 1
                line = line.strip()
                chunks = line.split("\t")
                # Get protein accession
                current_protein_acc = chunks[0]
                num_of_proteins = len(current_protein_acc.split("|"))
                # If new protein accession extracted, store GO annotation counts in result dictionary
                if not current_protein_acc == previous_protein_acc:
                    total_num_of_proteins += 1
                    if len(go_annotations_single_protein) > 0:
                        num_of_proteins_with_go += 1

                    previous_protein_acc = current_protein_acc
                    GOSummaryUtils.count_and_assign_go_annotations(go2protein_count, go_annotations_single_protein,
                                                                   num_of_proteins)
                    # reset go id set because we hit a new protein accession
                    go_annotations_single_protein = set()
                # Parse out GO annotations
                # GO annotations are associated to InterPro entries (InterPro entries start with 'IPR')
                # Than use the regex to extract the GO Ids (e.g. GO:0009842)
                if len(chunks) >= 13 and chunks[11].startswith("IPR"):
                    for go_annotation in goPattern.findall(line):
                        go_annotations_single_protein.add(go_annotation)

            # Do final counting for the last protein
            GOSummaryUtils.count_and_assign_go_annotations(go2protein_count, go_annotations_single_protein,
                                                           num_of_proteins)
            total_num_of_proteins += 1

            handle.close()
            processing_stats = ParsingStats(num_of_lines=line_counter,
                                            num_of_proteins=total_num_of_proteins,
                                            proteins_with_go=num_of_proteins_with_go,
                                            num_of_unique_go_ids=len(go2protein_count))
        return go2protein_count, processing_stats

    @staticmethod
    def parse_mapped_gaf_file(gaf_file):
        """
        parse_mapped_gaf_file(gaf_file) -> dictionary
        Example of GAF mapped output:
            !gaf-version: 2.0
            ! This GAF has been mapped to a subset:
            ! Subset: user supplied list, size = 38
            ! Number of annotation in input set: 1326
            ! Number of annotations rewritten: 120
            EMG	GO:0005839	GO		GO:0005839	PMID:12069591	IEA		C			protein	taxon:1310605	20160528	InterPro
            EMG	GO:0000160	GO		GO:0005575	PMID:12069591	IEA		C			protein	taxon:1310605	20160528	InterPro
        Parsing the above GAF file will create the following dictionary:
        result = {'GO:0005839':'GO:0005839', 'GO:0000160':'GO:0005575'}
        :param gaf_file:
        :return:
        """
        result = {}
        if GOSummaryUtils.__pathExists(gaf_file):
            handle = GOSummaryUtils.__fileOpen(gaf_file, "r")
            for line in handle:
                if not line.startswith("!"):
                    line = line.strip()
                    splitted_line = line.split("\t")
                    go_id = splitted_line[1]
                    mapped_go_id = splitted_line[4]
                    result.setdefault(go_id, set()).add(mapped_go_id)
        return result

    @staticmethod
    def writeGoSummaryToFile(goSummary, outputFile):
        handle = GOSummaryUtils.__fileOpen(outputFile, "w")
        for go, term, category, count in goSummary:
            handle.write('","'.join(['"' + go, term, category, str(count) + '"']) + "\n")
        handle.close()

    @staticmethod
    def get_memory_info(process):
        """
        get_memory_info(process) -> string
        :param process: Represents an OS process object instantiated by module psutil.
        :return: Returns the memory usage in MB.
        """
        factor = 1024 * 1024
        result = "Resident memory: " + str(process.memory_info().rss / factor) + "MB. Virtual memory: " + str(
                process.memory_info().vms / factor) + "MB"
        return result

    @staticmethod
    def create_gaf_file(gaf_input_file_path, go_id_set):
        """
        :param gaf_input_file_path:
        :param go2proteinDict:
        :return: nothing
        """
        with io.open(gaf_input_file_path, 'w') as file:
            file.write(u'!gaf-version: 2.1\n')
            file.write(u'!Project_name: EBI Metagenomics\n')
            file.write(u'!URL: http://www.ebi.ac.uk/metagenomics\n')
            file.write(u'!Contact Email: metagenomics-help@ebi.ac.uk\n')
            for go_id in go_id_set:
                gaf_file_entry_line_str = 'EMG\t{0}\t{1}\t\t{2}\tPMID:12069591\tIEA\t\t{3}\t\t\tprotein\ttaxon:1310605\t{4}\t{5}\t\t'.format(
                        go_id,
                        'GO',
                        go_id,
                        'P',
                        '20160528',
                        'InterPro')
                file.write(u'' + gaf_file_entry_line_str + '\n')

    @staticmethod
    def count_and_assign_go_annotations(go2protein_count, go_annotations, num_of_proteins):
        for go_id in go_annotations:
            count = go2protein_count.setdefault(go_id, 0)
            count += 1 * num_of_proteins
            go2protein_count[go_id] = count

    @staticmethod
    def count_slims(go_annotations_single_protein, map2slim_mapped_go_ids_dict, num_of_proteins, result):
        # count goslims
        slim_go_ids_set = set()
        # Get the set of slim terms
        for go_annotation in go_annotations_single_protein:
            mapped_go_ids = map2slim_mapped_go_ids_dict.get(go_annotation)
            if mapped_go_ids:
                slim_go_ids_set.update(mapped_go_ids)
        # Iterate over the set of slim terms and update the counts
        for slim_go_id in slim_go_ids_set:
            count = result.setdefault(slim_go_id, 0)
            count += 1 * num_of_proteins
            result[slim_go_id] = count

    @staticmethod
    def parse_iprscan_output_goslim_counts(iprscanOutput, map2slim_mapped_go_ids_dict):
        # result -> GO accessions mapped to number of occurrences
        # Example {'GO:0009842':267, 'GO:0009841':566}
        result = {}
        if GOSummaryUtils.__pathExists(iprscanOutput):
            handle = GOSummaryUtils.__fileOpen(iprscanOutput, "r")
            # Example GO Id -> GO:0009842
            goPattern = re.compile("GO:\d+")
            line_counter = 0
            previous_protein_acc = None
            go_annotations_single_protein = set()
            # Set default value for number of proteins to 1
            num_of_proteins = 1
            for line in handle:
                line_counter += 1
                line = line.strip()
                chunks = line.split("\t")
                # Get protein accession
                current_protein_acc = chunks[0]
                num_of_proteins = len(current_protein_acc.split("|"))
                # If new protein accession extracted, store GO annotation counts in result dictionary
                if not current_protein_acc == previous_protein_acc:
                    previous_protein_acc = current_protein_acc
                    GOSummaryUtils.count_slims(go_annotations_single_protein, map2slim_mapped_go_ids_dict,
                                               num_of_proteins, result)
                    # reset go id set because we hit a new protein accession
                    go_annotations_single_protein = set()
                # Parse out GO annotations
                # GO annotations are associated to InterPro entries (InterPro entries start with 'IPR')
                # Than use the regex to extract the GO Ids (e.g. GO:0009842)
                if len(chunks) >= 13 and chunks[11].startswith("IPR"):
                    for go_annotation in goPattern.findall(line):
                        go_annotations_single_protein.add(go_annotation)

            # Do final counting for the last protein
            GOSummaryUtils.count_slims(go_annotations_single_protein, map2slim_mapped_go_ids_dict,
                                       num_of_proteins, result)
            handle.close()
        return result

    @staticmethod
    def random_word(Length):
        from random import randint
        assert (1 <= Length <= 26)  # Verify 'Length' is within range
        charlist = [c for c in "abcdefghijklmnopqrstuvwxyz"]
        for i in xrange(0, Length):
            other = randint(0, 25)
            charlist[i], charlist[other] = charlist[other], charlist[i]  # Scramble list by swapping values
        word = ""
        for c in charlist[0:Length]: word += c
        return word.upper()


def run_map2slim(owltools_bin, core_gene_ontology_obo_file, metagenomics_go_slim_ids_file,
                 gaf_input_full_path, gaf_output_full_path):
    try:
        output = subprocess.check_output(
                [
                    owltools_bin,
                    core_gene_ontology_obo_file,
                    '--gaf',
                    gaf_input_full_path,
                    '--map2slim',
                    '--idfile',
                    metagenomics_go_slim_ids_file,
                    '--write-gaf',
                    gaf_output_full_path
                ], stderr=subprocess.STDOUT, )
        # print output
    except subprocess.CalledProcessError, ex:
        print "--------error------"
        print ex.cmd
        print ex.message
        print ex.returncode
        print ex.output
        raise
    except:
        print "Unexpected error:", sys.exc_info()[0]
        raise


if __name__ == '__main__':
    description = "Go slim pipeline."
    #    Parse script parameters
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("-c", "--config",
                        type=file,
                        help="path to config file",
                        required=False,
                        metavar="configfile",
                        default="config/go_summary-config.json")
    parser.add_argument("-i", "--input-file",
                        help="InterProScan result file.",
                        required=True)
    parser.add_argument("-o", "--output-file",
                        help="GO summary output file.",
                        required=True)
    args = vars(parser.parse_args())
    print "INFO: " + description

    script_pathname = os.path.dirname(sys.argv[0])
    script_full_path = os.path.abspath(script_pathname)

    # InterProScan result file including the GO annotations
    iprscan_output_file = args['input_file']
    output_file = args['output_file']

    if not os.stat(iprscan_output_file).st_size == 0:
        # Get program configuration
        configuration = json.load(args['config'])
        temp_dir = configuration["temp_dir"]
        # Create unique temporary file prefix
        date_stamp = time.strftime("%Y%m%d%H%M%S")
        random_word = GOSummaryUtils.random_word(8)
        temp_file_prefix = date_stamp + "_" + random_word + "_"

        # path to the latest version of the core gene ontology in OBO format
        full_gene_ontology_obo_formatted = ''.join([script_full_path, '/', configuration["full_gene_ontology_obo_file"]])

        # GO slim banding file
        go_slim_banding_file = ''.join([script_full_path, '/', configuration["metagenomics_go_slim_banding_file"]])

        # Map2Slim program parameters
        metagenomics_go_slim_ids_file = ''.join([script_full_path, '/', configuration["metagenomics_go_slim_ids_file"]])
        owltools_bin = ''.join([script_full_path, '/', configuration["owltools_bin_file"]])

        # psutil is a library for retrieving information on running processes
        process = psutil.Process(os.getpid())
        print "Process id: " + str(os.getpid())
        print "Initial memory: " + GOSummaryUtils.get_memory_info(process)

        # Create temporary file names, necessary to run map2slim
        gaf_input_temp_file_path = temp_dir + temp_file_prefix + 'pipeline_input_annotations.gaf'
        gaf_output_temp_file_path = temp_dir + temp_file_prefix + 'pipeline_mapped_annotations.gaf'
        print "Creating temp files under: " + gaf_input_temp_file_path

        # Parse InterProScan result file; map protein accessions and GO terms
        print "Parsing the InterProScan result output file: " + iprscan_output_file
        go2protein_count_dict, processing_stats = GOSummaryUtils.parseIprScanOutput(iprscan_output_file)
        print "Finished parsing."
        print "After parsing the InterProScan result file: " + GOSummaryUtils.get_memory_info(process)

        # Generate GO summary
        print "Loading full Gene ontology: " + full_gene_ontology_obo_formatted
        core_gene_ontology_list = GOSummaryUtils.get_gene_ontology(full_gene_ontology_obo_formatted)
        print "Finished loading."
        print "After loading the full Gene ontology: " + GOSummaryUtils.get_memory_info(process)

        print "Generating full GO summary..."
        topLevelGoIds = ['GO:0008150', 'GO:0003674', 'GO:0005575']
        full_go_summary = GOSummaryUtils.getFullGOSummary(core_gene_ontology_list, go2protein_count_dict, topLevelGoIds)
        print "After generating the full GO summary: " + GOSummaryUtils.get_memory_info(process)
        # delete core gene ontology list
        del core_gene_ontology_list
        print "Finished generation."

        print "Writing full GO summary to the following file: " + output_file
        GOSummaryUtils.writeGoSummaryToFile(full_go_summary, output_file)
        # delete full GO summary variable
        del full_go_summary
        print "Finished writing."

        # Generating the GAF input file for Map2Slim
        print "Generating the GAF input file for Map2Slim..."
        go_id_set = go2protein_count_dict.keys()
        # delete GO to protein dictionary variable
        del go2protein_count_dict
        GOSummaryUtils.create_gaf_file(gaf_input_temp_file_path, go_id_set)
        num_of_gaf_entries = len(go_id_set)
        del go_id_set
        print "Finished GAF file generation."

        # Generate GO slim
        # Run Map2Slim for more information on how to use the tool see https://github.com/owlcollab/owltools/wiki/Map2Slim
        print "Memory before running Map2Slim: " + GOSummaryUtils.get_memory_info(process)
        print "Running Map2Slim now..."
        run_map2slim(owltools_bin, full_gene_ontology_obo_formatted, metagenomics_go_slim_ids_file,
                     gaf_input_temp_file_path, gaf_output_temp_file_path)
        print "Map2Slim finished!"

        print "Parsing mapped annotations..."
        go2mapped_go = GOSummaryUtils.parse_mapped_gaf_file(gaf_output_temp_file_path)
        print "Finished parsing."

        print "Getting GO slim counts by parsing I5 TSV again"
        go_slims_2_protein_count = GOSummaryUtils.parse_iprscan_output_goslim_counts(iprscan_output_file, go2mapped_go)
        print "After getting GO slim counts: " + GOSummaryUtils.get_memory_info(process)

        go_slim_summary = GOSummaryUtils.get_go_slim_summary(go_slim_banding_file, go_slims_2_protein_count)
        go_slim_output_file = output_file + '_slim'
        print "Writing GO slim summary to the following file: " + go_slim_output_file
        GOSummaryUtils.writeGoSummaryToFile(go_slim_summary, go_slim_output_file)
        # delete full GO summary variable
        del go_slim_summary
        print "Finished writing."

        # deleting temporary files
        try:
            os.remove(gaf_input_temp_file_path)
            os.remove(gaf_output_temp_file_path)
        except OSError:
            pass
        except:
            raise

        "============Statistics============"
        print "Parsed " + str(processing_stats.num_of_lines) + " lines in the InterProScan result file."
        print "Found " + str(processing_stats.num_of_proteins) + " proteins in the InterProScan result file."
        print str(processing_stats.proteins_with_go) + " out of " + str(
                processing_stats.num_of_proteins) + " proteins do have GO annotations."
        print "Found " + str(
                processing_stats.num_of_unique_go_ids) + " unique GO identifiers in the InterProScan result file."
        print "Created " + str(num_of_gaf_entries) + " GAF entries to feed Map2Slim."

        print "Program finished."
    else:
        with open("empty.summary.go", "w") as empty_summary:
            empty_summary.close()
        with open("empty.summary.go_slim", "w") as empty_slim:
            empty_slim.close()
        sys.stdout.write("input file empty, writing empty output files")
        sys.stderr.write("input file empty, writing empty output files")
