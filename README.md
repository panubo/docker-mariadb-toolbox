# MariaDB Toolbox

A collection of MySQL / MariaDB scripts for automating common DBA tasks in a Docker-centric way.

Wherever possible the commands are compatible with Amazon RDS and GCP Cloud SQL.

## Documentation

Documentation for each subcommand:

- [backup](commands/backup.md)
- [check](commands/check.md)
- [convert-to-innodb](commands/convert-to-innodb.md)
- [copy-database](commands/copy-database.md)
- [create-user-db](commands/create-user-db.md)
- [import](commands/import.md)
- [load](commands/load.md)
- [mysql](commands/mysql.md)
- [save](commands/save.md)

## General Usage

Using Docker links to `mariadb` container:

```
docker run --rm -i -t --link myserver:mariadb docker.io/panubo/mariadb-toolbox:1.6.0
```

This will display the usage information.

```
docker run --rm -i -t --link myserver:mariadb docker.io/panubo/mariadb-toolbox:1.6.0 <subcommand>
```

To run the subcommand.

## Configuration

Use `--link <mariadb container name>:mariadb` to automatically specify the required variables.

Or alternatively specify the variables:

- `DATABASE_HOST` = IP / hostname of MariaDB / MySQL server.
- `DATABASE_PORT` = TCP Port of MariaDB / MySQL service.
- `DATABASE_USER` = Administrative user eg root with CREATEDB privileges.
- `DATABASE_PASS` = Password of administrative user.

Some subcommands require additional environment parameters. See the
documentation for the subcommand for more information.

## Status

Stable.
