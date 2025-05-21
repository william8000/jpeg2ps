#!/bin/sh
# nightly_build.sh -- build jpeg2ps from git

rm -f nightly_build.log

(
 echo "Starting nightly_build $* at $(date) in $(pwd)"
 make "$@" all
) 2>&1 | tee nightly_build.log
