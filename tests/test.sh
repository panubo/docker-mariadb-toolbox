#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

CWD="$(dirname $0)/"

. ${CWD}functions.sh

echo "=> Test backup command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -t -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup $TEST_CONTAINER backup
cleanup mariadb $TEST_NAME

echo "=> Test check command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -t -i --name $TEST_NAME --link mariadb $TEST_CONTAINER check
cleanup mariadb $TEST_NAME

echo "=> Test copy-database command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -t -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup -v /tmp/data:/data $TEST_CONTAINER copy-database mysql mysql-backup
cleanup mariadb $TEST_NAME

echo "=> Test convert-to-innodb command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
(
echo "CREATE DATABASE foodb;"
echo "USE foodb; CREATE TABLE testtable (a INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (a)) ENGINE=MyISAM;"
) | docker run --rm -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup $TEST_CONTAINER mysql
docker run -t -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup $TEST_CONTAINER convert-to-innodb foodb
cleanup mariadb $TEST_NAME

echo "=> Test create-user-db command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -t -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup $TEST_CONTAINER create-user-db foo foopass
cleanup mariadb $TEST_NAME

echo "=> Test import command"
mkdir -p /tmp/data
(
echo "CREATE TABLE testtable (a INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (a)) ENGINE=MyISAM;"
) | gzip > /tmp/data/foodb.sql.gz
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -t -i --name $TEST_NAME --link mariadb -e DATA_SRC=/data -v /tmp/data:/data $TEST_CONTAINER import
cleanup mariadb $TEST_NAME

echo "=> Test load command"
echo "TODO"

echo "=> Test mysql command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
echo "SHOW DATABASES;" | docker run -i --name $TEST_NAME --link mariadb $TEST_CONTAINER mysql
cleanup mariadb $TEST_NAME

echo "=> Test save command"
echo "TODO"
