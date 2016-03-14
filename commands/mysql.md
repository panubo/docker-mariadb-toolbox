# MySQL Client

Command to start an interactive MySQL client session.

## Configuration

Use `--link <mariadb container name>:mariadb` to automatically specify the required variables.

Alternatively specify the individual variables:

- `DATABASE_HOST` = IP / hostname of MariaDB / MySQL server.
- `DATABASE_USER` = Administrative user eg root with CREATEDB privileges.
- `DATABASE_PASS` = Password of administrative user.
- `DATA_SRC` = Data source. This is where your dumps are.

