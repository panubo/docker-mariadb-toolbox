#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

CWD="$(dirname $0)/"

. ${CWD}functions.sh

echo "=> Starting $0"
start_docker
unset DOCKER_HOST # https://github.com/docker-library/docker/issues/200#issuecomment-550089770
check_docker
check_environment
cleanup
build_image

for T in ${CWD}test*.sh; do
    echo "==> Executing Test $T"
    ${T}
done

cleanup
echo "=> Done!"
