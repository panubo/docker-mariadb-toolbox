# Convert to InnoDB

Command to convert a MySQL / MariaDB database to InnoDB backend.

## Configuration

Use `--link <mariadb container name>:mariadb` to automatically specify the required variables.

Alternatively specify the individual variables:

- `DATABASE_HOST` = IP / hostname of MariaDB / MySQL server.
- `DATABASE_USER` = Administrative user eg root with CREATEDB privileges.
- `DATABASE_PASS` = Password of administrative user.
- `DATA_SRC` = Data source. This is where your dumps are.

### Options

- `<databases>...` name of database(s) to convert.

## Usage Example

```
docker run --rm -i -t -e DATABASE_HOST=172.19.66.4 -e DATABASE_USER=root -e DATABASE_PASS=foo docker.io/panubo/mariadb-toolbox:1.6.0 convert-to-innodb <database>
```
