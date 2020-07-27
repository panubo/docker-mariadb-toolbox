# Save databases

Command to backup databases and place in a timestamped directory on object storage. `save` has more options than `backup`.

## Usage

```
Usage: save [GLOBAL_OPTIONS] [OPTIONS] [DATABASE...] DESTINATION
Global Options: (where possible these options match mysql options)
    -h|--host    host to connect to
    -P|--port    post to connect to
    -u|--user    user to connect with
    -D|--database    database to connect to
    -p|--password    password to connection to (not recommended. Use password-file)
    --password-file    password file to read password from

Options:
    --compression    gzip|lz4|bz2|none
    --date-format    %Y%m%d%H%M%S
    --checksum    sha256
    --umask    0077

    DATABASE    database(s) to dump. Will dump all if no databases are specified.
    DESTINATION    Destination to save database dumps to. s3://, gs:// and files are supported.

Environment variables:
    Any global options can be prefixed with DATABASE_ and specified via environment variable.
    Any save command options can be prefixed with SAVE_ and specified via environment variable.
```
