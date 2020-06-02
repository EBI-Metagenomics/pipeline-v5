#!/bin/bash

# Biom convert wrapper - because Toil doesn't set the locale variables LC_ALL and LANG
export LC_ALL="en_US.UTF-8"
export LANG="en_US.UTF-8"

biom convert "$@"