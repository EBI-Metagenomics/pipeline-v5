#!/bin/bash
export PATH="$HOME/node-v8.11.1:$PATH"


# scripts path
#SCRIPTS_PATHS=$(readlink -f "../../bin")
#PATH="$SCRIPTS_PATHS":$PATH

cwltest "$@" --tool cwltool -- --enable-dev