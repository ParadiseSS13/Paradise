#!/bin/bash
set -euo pipefail

# Waits for the MariaDB that CI started in the background to take connections
if ! timeout 120 bash -c 'until mysql -h 127.0.0.1 -u root -proot -e "SELECT 1" > /dev/null 2>&1; do sleep 1; done'; then
  echo "MariaDB didn't start within 120 seconds"
  cat "$RUNNER_TEMP/mariadb.log" || true
  docker logs mariadb || true
  exit 1
fi
