# Load Database

Command to load a sql dump from object storage (or filesystem) to a destination database.

## Features

* Automatic compression detection
* DROP and CREATE destination database
* Support for sed filters
* gsutil auth helper
* Source can either be a bucket root with timestamped directories named with the date ie 20200813000000 (must be 14 chars),
or a path to the dump to restore, or a date stamped path (or partial datestamp), eg `s3://mybucket`, or `s3://mybucket/20200813000000`, or `s3://mybucket/20200813000000/my_database.sql.lz4`
