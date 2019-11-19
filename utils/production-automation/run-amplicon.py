#!/usr/bin/env /hps/nobackup2/production/metagenomics/pipeline/tools-v5/miniconda3-4.6.14/bin/python3
import logging
import os
import re
import yaml
import argparse
from subprocess import CalledProcessError
from subprocess import check_output

cwlSingle = '/hps/nobackup2/production/metagenomics/pipeline/tools-v5/pipeline-v5/workflows/amplicon-wf-single-empty.cwl'
cwlPaired = '/hps/nobackup2/production/metagenomics/pipeline/tools-v5/pipeline-v5/workflows/amplicon-wf-paired-empty.cwl'
ymlSingle = '/hps/nobackup2/production/metagenomics/pipeline/tools-v5/pipeline-v5/workflows/amplicon-wf-single-job.yml'
ymlPaired = '/hps/nobackup2/production/metagenomics/pipeline/tools-v5/pipeline-v5/workflows/amplicon-wf-paired-job.yml'
toil_mem= '30G'
amplicon_mem= 20000
stats_mem = 1000
restart_mem= 10000
toil_cores = 4.0
lsf_cores = 4
groupname = '/toil-test'
queue = 'production-rh74'

def setup_dir(projectID, pathtoProject):
    runDict = {}
    readPath = os.path.join(pathtoProject, 'raw')
    for file in os.listdir(readPath):
        runName = re.findall('(\w+).fastq', file)[0]
        runNameStrip = runName.split("_")[0]
        if not runNameStrip in runDict:
            if '_' in runName:
                runDict[runNameStrip] = 'paired'
            else:
                runDict[runNameStrip] = 'single'
    workDir = pathtoProject
    outDir = os.path.join(pathtoProject, projectID + '-v5-annotation')
    os.mkdir(outDir)
    return [runDict, workDir, outDir]

def yml_files(dictValue, workDir):
    key = dictValue[0]
    value = dictValue[1]
    newName = key + '.yml'
    with open(os.path.join(workDir, newName), "w") as newFile:
        if value == 'paired':
            with open (ymlPaired, "r") as ymlFile:
                data = yaml.safe_load(ymlFile)
                data['forward_reads']['path'] = "raw/" + key + "_1.fastq.gz"
                data['reverse_reads']['path'] = "raw/" + key + "_2.fastq.gz"
                yaml.safe_dump(data, newFile)
        else:
            with open (ymlSingle, "r") as ymlFile:
                data = yaml.safe_load(ymlFile)
                data['single_reads']['path'] = "raw/" + key + ".fastq.gz"
                yaml.safe_dump(data, newFile)
    return [newName, value]

def toil_command(ymlFile, type, workDir, outDir):
    runID = ymlFile.split(".")[0]
    if type == 'paired':
        cwl = cwlPaired
    else:
        cwl = cwlSingle
    job_toil_folder = os.path.join(workDir, runID)
    log_dir = os.path.join(outDir, 'logs_' + runID)
    tmp_dir = os.path.join(workDir, 'global-temp-dir_' + runID)
    out_tool = os.path.join(outDir, runID)
    yml_path = os.path.join(workDir, ymlFile)
    os.mkdir(log_dir)
    os.mkdir(tmp_dir)
    os.mkdir(out_tool)
    run_cmd = f"export TOIL_LSF_ARGS='-q {queue} -g {groupname}' && "\
              f"cwltoil --no-container --stats --batchSystem LSF "\
              f"--disableCaching --defaultMemory {toil_mem} --jobStore {job_toil_folder} --outdir {out_tool} "\
              f"--realTimeLogging --logDebug --maxLogFileSize 0 --retryCount 3 --defaultCores {toil_cores} --writeLogs {log_dir} "\
              f"--logFile {log_dir}/{runID}.log {cwl} {yml_path}"
    restart_cmd = f"if grep -q 'Job used more disk than requested' {log_dir}/{runID}.log; then "\
                  f"source /hps/nobackup2/production/metagenomics/pipeline/testing/varsha/test_env.rc && "\
                  f"export PATH=$PATH:/homes/emgpr/.nvm/versions/node/v12.10.0/bin/ && "\
                  f"source /hps/nobackup2/production/metagenomics/pipeline/tools-v5/toil-user-env/bin/activate && "\
                  f"echo 'restarting with more memory....' && export TOIL_LSF_ARGS='-q {queue} -g {groupname}' && "\
                  f"cwtoil --no-container --stats --batchSystem LSF --disableCaching --defaultMemory {restart_mem} "\
                  f"--jobStore {job_toil_folder} --restart --outdir {out_tool} --realTimeLogging --logDebug "\
                  f"--maxLogFileSize 0 --retryCount 0 --defaultCores {toil_cores} --writeLogs {log_dir} --logFile {log_dir}/{runID}.log "\
                  f"{cwl} {yml_path}; fi"
    stats_cmd = f"if find {out_tool} -mindepth 1 -print -quit 2>/dev/null | grep -q .; then echo 'toil finished successfully' && " \
                f"source /hps/nobackup2/production/metagenomics/pipeline/tools-v5/toil-user-env/bin/activate && " \
                f"toil stats {job_toil_folder} > {outDir}/{runID}.stats && "\
                f"toil clean {job_toil_folder} && "\
                f"toil clean {tmp_dir}; "\
                f"else echo 'output folder empty. Toil workflow failed somewhere'; fi"
    return run_cmd, restart_cmd, stats_cmd
    #add step to move yml files into folder


def bsub(cmd, err_file=None, dry_mode=None, main=False, restart=False, stats=False, jobID=None):
    memory = message = ''
    if main:
        message = 'Launching workflow'
        memory = toil_mem
    elif restart:
        message = 'Launching memory check'
        memory = restart_mem
    elif stats:
        message = 'Launching stats and directory cleanup'
        memory = stats_mem
    bsub_cmd = f'bsub -q {queue} -M {memory} -g {groupname} -n {lsf_cores}'
    wait_cmd = f"-w 'ended({jobID})'"
    if restart or stats:
        final_cmd = f"{bsub_cmd} {wait_cmd} \"{cmd}\""
    else:
        final_cmd = f"{bsub_cmd} \"{cmd}\""
    if err_file:
        bsub_cmd += ' -e {err_file}'
    if dry_mode:
        logging.info(f'Launching cmd: {cmd}')
        return 0
    try:
        stdout = check_output(final_cmd, shell=True).decode()
    except CalledProcessError as exc:
        print("Status : FAIL", exc.returncode, exc.stderr, exc.stdout)
        raise exc
    outID = re.findall(r'<(\d+)>', str(stdout))[0]
    print (f"{message}...{stdout}")
    return outID

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="run toil for all runs in a project")
    parser.add_argument("--dir", dest="input_dir", help="path to input directory", required=True)
    parser.add_argument("--project", dest="projectID", help="Secondary Project identifier", required=True)
    #parser.add_argument("--restart_mem", dest="bigmem", help="if more memory required", required=False)
    #parser.add_argument("--run", dest='run_accession', help="run requiring higher memory", required=False)
    #20G plus 10G restart mem. Add flag for higher mem required.

    args = parser.parse_args()
    gen_dirs = setup_dir(projectID=args.projectID, pathtoProject=args.input_dir)
    runs = gen_dirs[0]
    for run in runs.items():
        gen_files = yml_files(run, gen_dirs[1])
        run_command = toil_command(gen_files[0], gen_files[1], gen_dirs[1], gen_dirs[2])
        mainID = bsub(run_command[0], main=True)
        restart = bsub(run_command[1], restart=True, jobID=mainID)
        clean = bsub(run_command[2], stats=True, jobID=restart)




