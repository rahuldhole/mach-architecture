#!/bin/sh

set -e

if [ -f tmp/pids/server.pid ]; then
  rm tmp/pids/server.pid
fi

echo "Waiting for Postgres to start..."
while ! nc -z postgres 5432; do sleep 0.1; done
echo "Postgres is up"

exec bundle exec "$@"
