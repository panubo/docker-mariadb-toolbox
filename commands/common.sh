#!/usr/bin/env bash

HOST=${DATABASE_HOST-${MARIADB_PORT_3306_TCP_ADDR-localhost}}
PORT=${DATABASE_PORT-${MARIADB_PORT_3306_TCP_PORT-3306}}
USER=${DATABASE_USER-root}
PASS=${DATABASE_PASS-${MARIADB_ENV_MYSQL_ROOT_PASSWORD}}
# This could be made db specific by using --defaults-file=
MYCONN="--user=${USER} --password=${PASS} --host=${HOST} --port=${PORT}"
MYSQL="mariadb ${MYCONN}"
MYSQLDUMP="mariadb-dump $MYCONN"
MYCHECK="mariadb-check ${MYCONN}"
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
            find_object="find_object_gs"
            ;;
        s3://*)
            echo ">> Storage type: aws s3"
            # Workaround for no environment variable for --endpoint-url https://github.com/aws/aws-cli/issues/4454
            AWS_S3_ADDITIONAL_ARGS=${AWS_S3_ADDITIONAL_ARGS-''}
            save_cmd=( "aws" "s3" "sync" "--no-progress" "${AWS_S3_ADDITIONAL_ARGS}" )
            ls_cmd=( "aws" "s3" "ls" "${AWS_S3_ADDITIONAL_ARGS}" )
            fetch_cmd=( "aws" "s3" "cp" "${AWS_S3_ADDITIONAL_ARGS}" )
            storage_type="s3"
            find_object="find_object_s3"
            ;;
        file://*|/*|./*)
            echo ">> Storage type: file"
            save_cmd=( "ls" )
            ls_cmd=( "ls" )
            fetch_cmd=( "cat" )
            source="${source#file:\/\/}"
            storage_type="file"
            find_object="find_object_file"
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

# this function is not actually called anywhere
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

# helper functions
function get_filename_from_object_path() {
  # Returns just the filename portion of the full object path
  echo "${1}" | sed -E -e 's/.*[\/ ]([^\/]*)$/\1/'
}

function get_basename_from_object_path() {
  # Returns just the bucketname / base path
  echo "${1}" | sed 's/\(file\|s3\|gs\):\/\/\([^\/]\+\)\/.*/\1:\/\/\2\//'
}

function get_timestamp_from_object_path() {
  # Returns just the timestamp portion of the full object path 2-14 digits
  echo "${1}" | sed -n 's/.*\/\([0-9]\{2,14\}\).*/\1/p; t; q;'
}

function check_object_exists() {
  if [[ $(eval "${ls_cmd[@]}" "${1}") ]]; then
    return 0
  else
    echoerr "Error file not found"
    return 1
  fi
}

function find_object_gs {
  # find the object
  # the following are are all valid
  # gs://mybucket/20230413000003/my_database.sql.lz4
  # gs://mybucket/20230413000003/ my_database
  # gs://mybucket/ my_database
  # gs://mybucket/20230413 my_database

  source="${1}"
  database="${2:-}"
  timestamp="$(get_timestamp_from_object_path "${source}")"
  base="$(get_basename_from_object_path "${source}")"

  if [[ "${timestamp}" == "" ]]; then
    # no timestamp in the path, find the latest
    timestamp="$(eval "${ls_cmd[@]}" "${source}" | sed -E -e '/[0-9]{14}/!d' -e 's/.*([0-9]{14})\/$/\1/' | sort | tail -n1)"
    full_path="$(eval "${ls_cmd[@]}" "${source}${timestamp}/" | grep "/${database}[\.\-]")"
  else
    # has timestamp, either fully qualified, or needs expanding
    if [[ $source =~ [0-9]{14}/${database} ]]; then
      # should be complete path
      full_path="${source}"
    elif [[ $source =~ [0-9]{14} ]]; then
      # complete timestamp
      full_path="$(eval "${ls_cmd[@]}" "${source}" | grep "/${database}[\.\-]")"
    else
      # partial timestamp. search for matching object path
      full_path="$(eval "${ls_cmd[@]}" "${base}${timestamp}*/" | grep "/${database}[\.\-]")"
    fi
  fi
  check_object_exists "${full_path}" || { echoerr "Error file not found"; exit 1; }
  echo "${full_path}"
}


function find_object_s3 {
  # find the object
  # the following are are all valid
  # s3://mybucket/20230413000003/my_database.sql.lz4
  # s3://mybucket/20230413000003/ my_database
  # s3://mybucket/ my_database
  # s3://mybucket/20230413 my_database

  source="${1}"
  database="${2:-}"
  timestamp="$(get_timestamp_from_object_path "${source}")"
  base="$(get_basename_from_object_path "${source}")"

  if [[ "${timestamp}" == "" ]]; then
    # no timestamp in the path, find the latest
    timestamp="$(eval "${ls_cmd[@]}" "${base}" | sed -E -e '/[0-9]{14}/!d' -e 's/.*([0-9]{14})\/$/\1/' | sort | tail -n1)"
    file="$(eval "${ls_cmd[@]}" "${base}${timestamp}/" | sed -E -e 's/.*[\/ ]([^\/]*)$/\1/' | grep "^${database}[\.\-]")"
    full_path="${base}${timestamp}/${file}"
  else
    # has timestamp, either fully qualified, or needs expanding
    if [[ $source =~ [0-9]{14}/${database} ]]; then
      # should be complete path
      full_path="${source}"
    elif [[ $source =~ [0-9]{14} ]]; then
      # complete timestamp
      file="$(eval "${ls_cmd[@]}" "${source}" | sed -E -e 's/.*[\/ ]([^\/]*)$/\1/' | grep "^${database}[\.\-]")"
      full_path="${source}${file}"
    else
      # partial timestamp. search for matching object path
      timestamp="$(eval "${ls_cmd[@]}" "${base}" | sed -E -e '/[0-9]{14}/!d' -e 's/.*([0-9]{14})\/$/\1/' | grep "${timestamp}")"
      timestamp_count=$(wc -l <<<"${timestamp}")
      [[ "${timestamp_count}" -gt 1 ]] && { echoerr "Error too many items found. Timestamp is not distinct."; exit 1; }
      file="$(eval "${ls_cmd[@]}" "${base}${timestamp}/" | sed -E -e 's/.*[\/ ]([^\/]*)$/\1/' | grep "^${database}[\.\-]")"
      full_path="${base}${timestamp}/${file}"
    fi
  fi
  check_object_exists "${full_path}" || { echoerr "Error file not found"; exit 1; }
  echo "${full_path}"
}

function find_object_file {
  echoerr "find_object_file not implemented"
  exit 1
}
