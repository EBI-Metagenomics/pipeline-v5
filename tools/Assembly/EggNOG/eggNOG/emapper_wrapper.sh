#!/bin/bash

set -e

MEMDIR="/dev/shm"
DB="eggnog.db"
SRCDIR=""

ARGS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --data_dir)
      SRCDIR="$2"
      shift # past argument
      shift # past value
      ARGS+=("--data_dir" "${MEMDIR}")
      ;;
    *)
      ARGS+=("$1")
      shift
      ;;
  esac
done

clean() {
    echo "Removing the db from ${MEMDIR}/${DB}"
    rm -f "${MEMDIR}/${DB}"
}

trap clean EXIT SIGINT SIGTERM

echo "Storing the eggnog.db sqlite in memory (/dev/shm)"

cp "${SRCDIR}/${DB}" "${MEMDIR}/${DB}"

emapper.py "${ARGS[@]}"
