# Docker MariaDB Toolbox

![build-push](https://github.com/panubo/docker-mariadb-toolbox/actions/workflows/build-push.yml/badge.svg)
[![release](https://img.shields.io/github/v/release/panubo/docker-mariadb-toolbox)](https://github.com/panubo/docker-mariadb-toolbox/releases/latest)
[![license](https://img.shields.io/github/license/panubo/docker-mariadb-toolbox)](LICENSE)

A versatile Docker image offering a collection of scripts to streamline common MySQL/MariaDB database administration tasks. This toolbox is designed with a Docker-centric approach, ensuring compatibility with Amazon RDS and GCP Cloud SQL wherever possible.

This image is available on quay.io `quay.io/panubo/mariadb-toolbox` and AWS ECR Public `public.ecr.aws/panubo/mariadb-toolbox`.

<!-- BEGIN_TOP_PANUBO -->
> [!IMPORTANT]
> **Maintained by Panubo** — Cloud Native & SRE Consultants in Sydney.
> [Work with us →](https://panubo.com.au)
<!-- END_TOP_PANUBO -->

## Features

- **Cloud Storage Integration:** Seamlessly backup and restore databases to and from **AWS S3** and **Google Cloud Storage (GCS)**.
- **Multiple Compression Formats:** Supports `gzip`, `bzip2`, `lz4`, and `xz` for efficient backups.
- **Automated DBA Tasks:** Simplifies common tasks like database backups, checks, conversions, and user creation.
- **Flexible Configuration:** Configure database connections and command options via environment variables or command-line arguments.
- **Extensible:** The toolbox is built on a modular design, allowing for the addition of new commands and functionalities.

## Available Commands

Here's a list of the available commands and their functions:

- [`backup`](./commands/backup.md): Dumps databases to a timestamped directory in a specified backup location.
- [`check`](./commands/check.md): Checks databases for errors and inconsistencies.
- [`convert-to-innodb`](./commands/convert-to-innodb.md): Converts a database's tables to the InnoDB storage engine.
- [`copy-database`](./commands/copy-database.md): Creates a copy of a database to a new database.
- [`create-user-db`](./commands/create-user-db.md): Creates a new user and a database with the same name.
- [`import`](./commands/import.md): Imports database dumps from a local directory.
- [`load`](./commands/load.md): Loads a database dump from object storage (AWS S3, GCS) or the local filesystem into a database.
- [`mysql`](./commands/mysql.md): Starts an interactive MySQL/MariaDB client session.
- [`save`](./commands/save.md): Saves database dumps to object storage (AWS S3, GCS) or the local filesystem with advanced options.

For more detailed information on each command, please refer to their respective documentation in the `commands` directory.

## General Usage

To use the MariaDB Toolbox, you can run the Docker image with the desired command. The following example shows how to display the usage information:

```shell
docker run --rm -it --link myserver:mariadb quay.io/panubo/mariadb-toolbox:1.10.0
```

To execute a specific command, append it to the `docker run` command:

```shell
docker run --rm -it --link myserver:mariadb quay.io/panubo/mariadb-toolbox:1.10.0 <subcommand>
```

### Configuration

The toolbox can be configured using environment variables. To connect to a database, you can either link to a MariaDB container named `mariadb` or provide the following variables:

- `DATABASE_HOST`: The IP address or hostname of the MariaDB/MySQL server.
- `DATABASE_PORT`: The TCP port of the MariaDB/MySQL service.
- `DATABASE_USER`: The administrative user with the necessary privileges.
- `DATABASE_PASS`: The password for the administrative user.

Additional environment variables may be required for specific commands. Please consult the documentation for each command for more details.

## Building the Image

To build the Docker image locally, you can use the `Makefile`:

```shell
make build
```

## Testing

The project includes a set of tests to ensure the functionality of the toolbox. To run the tests, use the following command:

```shell
make test
```

This will run the tests in a Docker-in-Docker environment. Alternatively, you can run the tests locally with:

```shell
make test-local
```

## License

This project is licensed under the [MIT License](LICENSE).

## Status

Stable.

<!-- BEGIN_BOTTOM_PANUBO -->
> [!IMPORTANT]
> ## About Panubo
>
> This project is maintained by Panubo, a technology consultancy based in Sydney, Australia. We build reliable, scalable systems and help teams master the cloud-native ecosystem.
>
> We are available for hire to help with:
>
> * SRE & Operations: Improving system reliability and incident response.
> * Platform Engineering: Building internal developer platforms that scale.
> * Kubernetes: Cluster design, security auditing, and migrations.
> * DevOps: Streamlining CI/CD pipelines and developer experience.
> * [See our other services](https://panubo.com.au/services)
>
> Need a hand with your infrastructure? [Let’s have a chat](https://panubo.com.au/contact) or email us at team@panubo.com.
<!-- END_BOTTOM_PANUBO -->
