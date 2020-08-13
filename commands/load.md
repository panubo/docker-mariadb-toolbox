# Load Database

Command to load a sql dump from object storage (or filesystem) to a destination database.

## Features

* Automatic compression detection
* DROP and CREATE destination database
* Support for sed filters
* gsutil auth helper

## Limitations

* Source must be a directory named with the date ie 20200813000000 (must be 14 chars)
* Only the latest is loadable
