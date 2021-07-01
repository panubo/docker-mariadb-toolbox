#!/usr/bin/env bash

HOST=${DATABASE_HOST-${MARIADB_PORT_3306_TCP_ADDR-localhost}}
PORT=${DATABASE_PORT-${MARIADB_PORT_3306_TCP_PORT-3306}}
USER=${DATABASE_USER-root}
PASS=${DATABASE_PASS-${MARIADB_ENV_MYSQL_ROOT_PASSWORD}}
# This could be made db specific by using --defaults-file=
MYCONN="--user=${USER} --password=${PASS} --host=${HOST} --port=${PORT}"
MYSQL="mysql ${MYCONN}"
MYSQLDUMP="mysqldump $MYCONN"
MYCHECK="mysqlcheck ${MYCONN}"
GZIP="gzip --fast"

# this function is not actually called anywhere
create_my_cnf() {
    (
        echo "[client]"
        echo "password=$PASS"
        echo "user=$USER"
        echo "host=$HOST"
        echo "port=$PORT"
    ) > ~/.my.cnf && chmod 600 ~/.my.cnf
}

wait_mariadb() {
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

genpasswd() {
  # Ambiguous characters have been been excluded
  CHARS="abcdefghijkmnpqrstuvwxyz23456789ABCDEFGHJKLMNPQRSTUVWXYZ"

  export LC_CTYPE=C  # Quiet tr warnings
  local length
  length="${1:-16}"
  set +o pipefail
  strings < /dev/urandom | tr -dc "${CHARS}" | head -c "${length}" | xargs
  set -o pipefail
}

echoerr() { echo "$@" 1>&2; }

get_storage_commands() {
    case "${1}" in
        gs://*)
            echo ">> Storage type: gsutil"
            save_cmd=( "gsutil" "rsync" )
            ls_cmd=( "gsutil" "ls" )
            fetch_cmd=( "gsutil" "cp" )
            storage_type="gs"
            gsutil_auth
            ;;
        s3://*)
            echo ">> Storage type: aws s3"
            # Workaround for no environment variable for --endpoint-url https://github.com/aws/aws-cli/issues/4454
            AWS_S3_ADDITIONAL_ARGS=${AWS_S3_ADDITIONAL_ARGS-''}
            save_cmd=( "aws" "s3" "sync" "--no-progress" "${AWS_S3_ADDITIONAL_ARGS}" )
            ls_cmd=( "aws" "s3" "ls" "${AWS_S3_ADDITIONAL_ARGS}" )
            fetch_cmd=( "aws" "s3" "cp" "${AWS_S3_ADDITIONAL_ARGS}" )
            storage_type="s3"
            ;;
        file://*|/*|./*)
            echo ">> Storage type: file"
            save_cmd=( "ls" )
            ls_cmd=( "ls" )
            fetch_cmd=( "cat" )
            source="${source#file:\/\/}"
            storage_type="file"
            ;;
        *)
            echoerr "Unknown storage type"
            exit 1
            ;;
    esac
}

get_compression_commands() {
  case "${1:-gzip}" in
      "gzip")
          file_ext+=( ".gz" )
          compression_cmd=( "gzip" "--fast" )
          decompression_cmd=( "gzip" "--fast" "-d" )
          ;;
      "lz4")
          file_ext+=( ".lz4" )
          compression_cmd=( "lz4" "-c" )
          decompression_cmd=( "lz4" "-c" "-d" )
          ;;
      "bz2"|"bzip2")
          file_ext+=( ".bz2" )
          compression_cmd=( "bzip2" "-c" )
          decompression_cmd=( "bzip2" "-c" "-d" )
          ;;
      "zip")
          echoerr "ZIP not implemented"
          exit 1
          ;;
      "none")
          compression_cmd=( "cat" )
          decompression_cmd=( "cat" )
          ;;
      *)
          echoerr "Unknown compression method"
          exit 1
          ;;
  esac
}

gsutil_auth() {
  if [[ -n "${SKIP_GSUIT_AUTH:-}" ]]; then
    return
  elif [[ -n "${GOOGLE_APPLICATION_CREDENTIALS:-}" ]]; then
    # if GOOGLE_APPLICATION_CREDENTIALS is set with a service account key
    printf "%s\n" \
      "[Credentials]" \
      "gs_service_key_file = ${GOOGLE_APPLICATION_CREDENTIALS}" > /etc/boto.cfg
  elif curl --max-time 2 -sSf 'http://169.254.169.254/computeMetadata/v1/instance/service-accounts/default/' -H "Metadata-Flavor: Google"; then
    # if GCE metadata is set and a default service-account is present
    printf "%s\n" \
      "[Credentials]" \
      "service_account = default" > /etc/boto.cfg
  fi
}
