# Backup databases

Command to backup databases and place in a either a timestamped local directory
or copied to any backend that [rclone](https://rclone.org) supports.

## Environment Configuration

Use `--link <mariadb container name>:mariadb` to automatically specify the required variables.

Or alternatively specify the individual variables:

- `DATABASE_HOST` = IP / hostname of MariaDB / MySQL server.
- `DATABASE_PORT` = TCP Port of MariaDB / MySQL service.
- `DATABASE_USER` = Administrative user eg root with DUMPDB privileges.
- `DATABASE_PASS` = Password of administrative user.

### Environment Options

- `BACKUP_DIR` local backup location
or
- `BACKUP_DESTINATION` object storage destination
- `BACKUP_TMP_DIR` temporary location for backup file ( default `/tmp`)

then specify [rclone environment](https://rclone.org/docs/#config-file) options for remote backends eg

- `RCLONE_CONFIG_S3_TYPE=s3`
- `RCLONE_CONFIG_S3_ACCESS_KEY_ID=XXX`
- `RCLONE_CONFIG_S3_SECRET_ACCESS_KEY=YYY`

### Options

- `<databases>...` name of database(s) to dump. If not specified all databases will be dumped.

## Example

```
docker run --rm -t -i --link myserver:mariadb -e BACKUP_DIR=/data -v /mnt/backup:/data docker.io/panubo/mariadb-toolbox backup db1 db2
```
