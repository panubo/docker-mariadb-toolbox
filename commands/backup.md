# Backup databases

Command to backup databases and place in a timestamped directory.

## Environment Configuration

Use `--link <mariadb container name>:mariadb` to automatically specify the required variables.

Or alternatively specify the individual variables:

- `DATABASE_HOST` = IP / hostname of MariaDB / MySQL server.
- `DATABASE_PORT` = TCP Port of MariaDB / MySQL service.
- `DATABASE_USER` = Administrative user eg root with DUMPDB privileges.
- `DATABASE_PASS` = Password of administrative user.

### Environment Options

- `BACKUP_DIR` backup location

### Options

- `<databases>...` name of database(s) to dump. If not specified all databases will be dumped.

## Example

```
docker run --rm -t -i --link mariadb -e BACKUP_DIR=/data -v /data:/mnt/data/tmp quay.io/panubo/mariadb-toolbox backup db1 db2

```
