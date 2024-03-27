#!/bin/sh
set -e

# Function to start the Rails server
start_server() {
  local port="$1"
  local rails_env="$2"

  if [ "$rails_env" = 'production' ]; then
    echo "Starting Rails server in production environment..."
  else
    echo "Installing bundle for development/test environment..."
    bundle install
    echo "Starting Rails server in development/test environment..."
  fi

  echo "Waiting for postgres to be ready..."
  while ! nc -z postgres 5432; do
    sleep 1
  done

  echo "Postgres is ready. Starting Rails server..."
  bundle exec rails server -b 0.0.0.0 -p "$port"
}

# Function to get env vars and set default values
env_defaults() {
  PORT=${PORT:-3000}
  RAILS_ENV=${RAILS_ENV:-"development"}
}

#! |\/| _ o _ 
#! |  |(_||| ) execution starts here
env_defaults  # Set default values
start_server "$PORT" "$RAILS_ENV"  # Start the Rails server
