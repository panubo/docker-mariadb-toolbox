# MySQL Client

Command to start an interactive MySQL client session.

## Configuration

Use `--link <mariadb container name>:mariadb` to automatically specify the required variables.

Alternatively specify the individual variables:

- `DATABASE_HOST` = IP / hostname of MariaDB / MySQL server.
- `DATABASE_USER` = Administrative user eg root with *CREATEDB* privileges.
- `DATABASE_PASS` = Password of administrative user.


## Usage Example

```
docker run --rm -i -t -e DATABASE_HOST=172.19.66.4 -e DATABASE_USER=root -e DATABASE_PASS=foo docker.io/panubo/mariadb-toolbox:1.6.0 mysql
```
