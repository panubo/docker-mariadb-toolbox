#!/usr/bin/env bash

set -e

[ "$DEBUG" == 'true' ] && set -x

CWD="$(dirname $0)/"

. ${CWD}functions.sh

echo "=> Test backup command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup $TEST_CONTAINER backup
cleanup mariadb $TEST_NAME

echo "=> Test check command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -i --name $TEST_NAME --link mariadb $TEST_CONTAINER check
cleanup mariadb $TEST_NAME

echo "=> Test convert-to-innodb command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
(
echo "CREATE DATABASE foodb;"
echo "USE foodb; CREATE TABLE testtable (a INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (a)) ENGINE=MyISAM;"
) | docker run --rm -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup $TEST_CONTAINER mysql
docker run -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup $TEST_CONTAINER convert-to-innodb foodb
cleanup mariadb $TEST_NAME

echo "=> Test copy-database command"
mkdir -p ${TMPDIR:-/tmp}/data
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup -v ${TMPDIR:-/tmp}/data:/data $TEST_CONTAINER copy-database mysql mysql-backup
cleanup mariadb $TEST_NAME
rm -f ${TMPDIR:-/tmp}/data/mysql.sql.gz
rmdir ${TMPDIR:-/tmp}/data

echo "=> Test create-user-db command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -i --name $TEST_NAME --link mariadb -e BACKUP_DIR=/backup $TEST_CONTAINER create-user-db foo foopass
cleanup mariadb $TEST_NAME

echo "=> Test create-user-db command (idempotency / password change)"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -i --name $TEST_NAME --link mariadb $TEST_CONTAINER create-user-db foo origpass && cleanup $TEST_NAME
# password should be changed
docker run -i --name $TEST_NAME --link mariadb $TEST_CONTAINER create-user-db foo changedpass && cleanup $TEST_NAME
echo "SHOW VARIABLES LIKE 'version';" | docker run -i --name $TEST_NAME --link mariadb -e DATABASE_USER=foo -e DATABASE_PASS=changedpass $TEST_CONTAINER mysql
cleanup $TEST_NAME
cleanup mariadb $TEST_NAME

echo "=> Test import command"
mkdir -p ${TMPDIR:-/tmp}/data
(
echo "CREATE TABLE testtable (a INT NOT NULL AUTO_INCREMENT, PRIMARY KEY (a)) ENGINE=MyISAM;"
) | gzip > ${TMPDIR:-/tmp}/data/foodb.sql.gz
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -i --name $TEST_NAME --link mariadb -e DATA_SRC=/data -v ${TMPDIR:-/tmp}/data:/data $TEST_CONTAINER import
cleanup mariadb $TEST_NAME
rm -f ${TMPDIR:-/tmp}/data/foodb.sql.gz
rmdir ${TMPDIR:-/tmp}/data

echo "=> Test load command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -d --name minio -p 9000:9000 ${MINIO_IMAGE}:${MINIO_TAG} server /data > /dev/null
docker run --rm -i --link minio -e MC_HOST_minio=http://minioadmin:minioadmin@minio:9000 minio/mc:latest --quiet mb minio/backup
docker run -i --name ${TEST_NAME}-save --link mariadb --link minio -e AWS_ACCESS_KEY_ID=minioadmin -e AWS_SECRET_ACCESS_KEY=minioadmin -e AWS_S3_ADDITIONAL_ARGS="--endpoint-url http://minio:9000" $TEST_CONTAINER save --host mariadb --password password s3://backup
docker run -i --name ${TEST_NAME}-load1 --link mariadb --link minio -e AWS_ACCESS_KEY_ID=minioadmin -e AWS_SECRET_ACCESS_KEY=minioadmin -e AWS_S3_ADDITIONAL_ARGS="--endpoint-url http://minio:9000" $TEST_CONTAINER load --host mariadb --password password s3://backup/ mysql newdb
docker run -i --name ${TEST_NAME}-load2 --link mariadb --link minio -e AWS_ACCESS_KEY_ID=minioadmin -e AWS_SECRET_ACCESS_KEY=minioadmin -e AWS_S3_ADDITIONAL_ARGS="--endpoint-url http://minio:9000" $TEST_CONTAINER load --host mariadb --password password s3://backup/202 mysql newdb
cleanup mariadb minio ${TEST_NAME}-save ${TEST_NAME}-load1 ${TEST_NAME}-load2

echo "=> Test mysql command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
echo "SHOW DATABASES;" | docker run -i --name $TEST_NAME --link mariadb $TEST_CONTAINER mysql
cleanup mariadb $TEST_NAME

echo "=> Test save command"
docker run -d --name mariadb -p 3306:3306 -e MYSQL_ROOT_PASSWORD=password ${MARIADB_IMAGE}:${MARIADB_TAG} > /dev/null
docker run -d --name minio -p 9000:9000 ${MINIO_IMAGE}:${MINIO_TAG} server /data > /dev/null
docker run --rm -i --link minio -e MC_HOST_minio=http://minioadmin:minioadmin@minio:9000 minio/mc:latest --quiet mb minio/backup
docker run -i --name $TEST_NAME --link mariadb --link minio -e AWS_ACCESS_KEY_ID=minioadmin -e AWS_SECRET_ACCESS_KEY=minioadmin -e AWS_S3_ADDITIONAL_ARGS="--endpoint-url http://minio:9000" $TEST_CONTAINER save --host mariadb --password password s3://backup
cleanup mariadb minio $TEST_NAME
