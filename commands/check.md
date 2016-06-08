# Check database

Command to check databases.

## Configuration

Use `--link <mariadb container name>:mariadb` to automatically specify the required variables.

Alternatively specify the individual variables:

- `DATABASE_HOST` = IP / hostname of MariaDB / MySQL server.
- `DATABASE_PORT` = TCP Port of MariaDB / MySQL service.
- `DATABASE_USER` = Administrative user eg root with DUMPDB privileges.
- `DATABASE_PASS` = Password of administrative user.

### Options

- `<databases>...` name of database(s) to check. If not specified all databases will be checked.

## Usage Example

```docker run --rm -i -t -e DATABASE_HOST=172.19.66.4 -e DATABASE_USER=root -e DATABASE_PASS=foo quay.io/panubo/mariadb-toolbox check```
