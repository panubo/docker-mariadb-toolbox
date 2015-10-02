# MariaDB Toolbox

[![Docker Repository on Quay.io](https://quay.io/repository/panubo/mariadb-toolbox/status "Docker Repository on Quay.io")](https://quay.io/repository/panubo/mariadb-toolbox)

A collection of MySQL / MariaDB tools for automating common tasks in a Docker-centric way.

## Documentation

Documentation for each subcommand:

- [Backup](commands/backup.md)
- [Create User](commands/create-user.md)
- [Convert to InnoDB](commands/convert-to-innodb.md)
- [Import](commands/import.md)

## Configuration

Use `--link <mariadb container name>:mariadb` to automatically specify the required variables.

Or alternatively specify the variables:

- `DATABASE_HOST` = IP / hostname of MariaDB / MySQL server.
- `DATABASE_PORT` = TCP Port of MariaDB / MySQL service.
- `DATABASE_USER` = Administrative user eg root with CREATEDB privileges.
- `DATABASE_PASS` = Password of administrative user.

## Usage

Using Docker links to `mariadb` container:

```docker run --rm -i -t --link mariadb:mariadb quay.io/panubo/mariadb-toolbox```

This will display the usage information.

## Status

Stable.