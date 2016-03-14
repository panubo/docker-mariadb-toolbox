#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

CWD="$(dirname $0)/"

. ${CWD}functions.sh

echo "=> Test backup command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password mariadb:latest > /dev/null
docker run -t -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup $TEST_CONTAINER backup
cleanup mariadb $TEST_NAME

echo "=> Test copy-database command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password mariadb:latest > /dev/null
docker run -t -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup -v /tmp/data:/data $TEST_CONTAINER copy-database mysql mysql-backup
cleanup mariadb $TEST_NAME

echo "=> Test create-user command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password mariadb:latest > /dev/null
docker run -t -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup $TEST_CONTAINER create-user foo foopass
cleanup mariadb $TEST_NAME

echo "=> Test convert-to-innodb command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password mariadb:latest > /dev/null
(
echo "CREATE DATABASE foodb;"
echo "USE foodb; CREATE TABLE testtable (a INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (a)) ENGINE=MyISAM;"
) | docker run --rm -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup $TEST_CONTAINER mysql
docker run -t -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup $TEST_CONTAINER convert-to-innodb foodb
cleanup mariadb $TEST_NAME

echo "=> Test import command"
echo "TODO"
