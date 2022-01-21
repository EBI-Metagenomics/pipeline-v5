#!/bin/bash

#################################################
# trimmomatic.jar is expected to be in the $PATH
#################################################

TRIMMOMATIC_JAR=$(which trimmomatic.jar)

CMD="java -jar ${TRIMMOMATIC_JAR} $@"

echo "${CMD}"

$CMD
