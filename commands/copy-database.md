# Copy Database

Command to copy a MySQL / MariaDB database.

## Configuration

Use `--link <mariadb container name>:mariadb` to automatically specify the required variables.

Alternatively specify the individual variables:

- `DATABASE_HOST` = IP / hostname of MariaDB / MySQL server.
- `DATABASE_PORT` = TCP Port of MariaDB / MySQL service.
- `DATABASE_USER` = Administrative user eg root with *CREATEDB* privileges.
- `DATABASE_PASS` = Password of administrative user.
- `DATA_SRC` = Data source. This is where your (temporary) dumps are stored.

### Options

- `--no-delete-database` don't delete destination database before loading dump.

## Usage Example

```
docker run --rm -i -t -v /mnt/data00/migrations:/data -e DATABASE_HOST=172.19.66.4 -e DATABASE_USER=root -e DATABASE_PASS=foo docker.io/panubo/mariadb-toolbox:1.6.0 copy-database <source-db> <destination-db>
```
