#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

. "$(dirname $0)/"common.sh

if [ -f "/commands/$1" ]; then
    exec "/commands/$@"
else
    echo "Running command $@"
    exec "$@"
fi
