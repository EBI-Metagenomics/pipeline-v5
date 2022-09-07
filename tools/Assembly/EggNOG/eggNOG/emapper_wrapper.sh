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
    if [ -n "${SRCDIR}" ]; then
        echo "Removing the db from ${MEMDIR}/${DB}"
        rm -f "${MEMDIR}/${DB}"
    fi
}

trap clean EXIT SIGINT SIGTERM

if [ -n "${SRCDIR}" ]; then
    echo "Storing the eggnog.db sqlite in memory (/dev/shm)"
    cp "${SRCDIR}/${DB}" "${MEMDIR}/${DB}"
fi

emapper.py "${ARGS[@]}"
