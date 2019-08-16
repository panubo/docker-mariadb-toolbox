# MariaDB Toolbox

[![CircleCI](https://circleci.com/gh/panubo/docker-mariadb-toolbox.svg?style=svg)](https://circleci.com/gh/panubo/docker-mariadb-toolbox)

A collection of MySQL / MariaDB scripts for automating common DBA tasks in a Docker-centric way.

## Documentation

Documentation for each subcommand:

- [Backup](commands/backup.md)
- [Check](commands/check.md)
- [Copy Database](commands/copy-database.md)
- [Convert to InnoDB](commands/convert-to-innodb.md)
- [Create User](commands/create-user.md)
- [MySQL](commands/mysql.md)
- [Import](commands/import.md)

## General Usage

Using Docker links to `mariadb` container:

```docker run --rm -i -t --link myserver:mariadb docker.io/panubo/mariadb-toolbox```

This will display the usage information.

```docker run --rm -i -t --link myserver:mariadb docker.io/panubo/mariadb-toolbox <subcommand>```

To run the subcommand.

## Configuration

Use `--link <mariadb container name>:mariadb` to automatically specify the required variables.

Or alternatively specify the variables:

- `DATABASE_HOST` = IP / hostname of MariaDB / MySQL server.
- `DATABASE_PORT` = TCP Port of MariaDB / MySQL service.
- `DATABASE_USER` = Administrative user eg root with CREATEDB privileges.
- `DATABASE_PASS` = Password of administrative user.

Some subcommands require additional environment parameters.

## Status

Stable.
