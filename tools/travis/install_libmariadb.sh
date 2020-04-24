#!/bin/bash
set -euo pipefail

wget http://www.byond.com/download/db/mariadb_client-2.0.0-linux.tgz
tar -xvf mariadb_client-2.0.0-linux.tgz
mv mariadb_client-2.0.0-linux/libmariadb.so ./
rm -rf mariadb_client-2.0.0-linux.tgz mariadb_client-2.0.0-linux

