#!/usr/bin/env bash

HOST=${DATABASE_HOST-${MARIADB_PORT_3306_TCP_ADDR-localhost}}
PORT=${DATABASE_PORT-${MARIADB_PORT_3306_TCP_PORT-3306}}
USER=${DATABASE_USER-root}
PASS=${DATABASE_PASS-${MARIADB_ENV_MYSQL_ROOT_PASSWORD}}
MYCONN="--user=${USER} --password=${PASS} --host=${HOST} --port=${PORT}"
MYSQL="mysql ${MYCONN}"
MYSQLDUMP="mysqldump $MYCONN"
MYCHECK="mysqlcheck ${MYCONN}"
GZIP="gzip --fast"


function wait_mariadb {
    # Wait for MariaDB to be available
    TIMEOUT=${3:-30}
    echo -n "Waiting to connect to MariaDB at ${1-$HOST}:${2-$PORT}"
    for (( i=0;; i++ )); do
        if [ ${i} -eq ${TIMEOUT} ]; then
            echo " timeout!"
            exit 99
        fi
        sleep 1
        (exec 3<>/dev/tcp/${1-$HOST}/${2-$PORT}) &>/dev/null && break
        echo -n "."
    done
    echo " connected."
    exec 3>&-
    exec 3<&-
}

function genpasswd() {
    export LC_CTYPE=C  # Quiet tr warnings
    local l=$1
    [ "$l" == "" ] && l=16
    set +o pipefail
    strings < /dev/urandom | tr -dc A-Za-z0-9_ | head -c ${l}
    set -o pipefail
}
