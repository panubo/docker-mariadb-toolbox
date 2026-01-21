#!/usr/bin/env bash
#
# This script is the entrypoint for the docker container. It checks if the
# command passed to it is one of the scripts in this directory, and if so,
# executes it. Otherwise, it executes the command directly.
#

set -e

[ "$DEBUG" == 'true' ] && set -x

. "$(dirname $0)/"common.sh

if [ -f "/commands/$1" ]; then
    exec "/commands/$@"
else
    echo "Running command $@"
    exec "$@"
fi
