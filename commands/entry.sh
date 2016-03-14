#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

. "$(dirname $0)/"common.sh

(
    echo "[client]"
    echo "password=$PASS"
    echo "user=$USER"
    echo "host=$HOST"
    echo "port=$PORT"
) > ~/.my.cnf && chmod 600 ~/.my.cnf

if [ -f "/commands/$1" ]; then
    exec "/commands/$@"
else
    echo "Running command $@"
    exec "$@"
fi
