#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

CWD="$(dirname $0)/"

. ${CWD}functions.sh

TEST_CONTAINER="dind-runner-$$"
DOCKERFILE="Dockerfile.test"

echo ">> Using Temp Dockerfile: $DOCKERFILE"

cat << EOF > $DOCKERFILE
FROM ${DIND_IMAGE}:${DIND_TAG}
RUN apk add bash curl
ADD .  /build/
WORKDIR /build
CMD ["/build/tests/runner.sh"]
EOF

echo ">> Building"
docker build -f $DOCKERFILE -t $TEST_CONTAINER .

echo ">> Running"
docker run --privileged -i --rm $TEST_CONTAINER

echo ">> Removing"
docker rmi $TEST_CONTAINER
rm -f $DOCKERFILE
