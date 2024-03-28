#!/bin/sh
set -e

# Function to start the Rails server
start_server() {
  local port="$1"
  local rails_env="$2"
  local database_host="$3"
  local database_port="$4"

  if [ "$rails_env" != 'production' ]; then
    echo "Installing bundle for $rails_env environment..."
    bundle install
  fi

  echo "Waiting for $database_host to be ready..."
  while ! nc -z "$database_host" $database_port; do
    sleep 1
  done
  echo "$database_host is ready..."

  echo "Creating and migrating database in $rails_env environment..."
  bin/rails db:create && bin/rails db:migrate
  
  echo "Starting Rails server in $rails_env environment..."
  bundle exec rails server -b 0.0.0.0 -p "$port"
}

# Function to get env vars and set default values
env_defaults() {
  PORT=${PORT:-3000}
  RAILS_ENV=${RAILS_ENV:-"development"}
  DATABASE_HOST=${DATABASE_HOST:-"postgres"}
  DATABASE_PORT=${DATABASE_PORT:-"5432"}

  echo "RAILS env $RAILS_ENV port $PORT | DB host $DATABASE_HOST port $DATABASE_PORT"
}

#! |\/| _ o _ 
#! |  |(_||| ) execution starts here
env_defaults  # Set default values
start_server "$PORT" "$RAILS_ENV" "$DATABASE_HOST" "$DATABASE_PORT"
