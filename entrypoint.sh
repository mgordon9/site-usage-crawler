#!/bin/bash
set -euxo pipefail

echo "lalalalalallalalalalal"
rm -f ./tmp/pids/server.pid

setup_database()
{
  echo "Checking database setup is up-to-date…"
  if rake db:migrate:status &> /dev/null; then
    echo "Database found, running db:migrate…"
    rake db:migrate
  else
    echo "No database found, running db:create db:schema:load…"
    rake db:create db:schema:load
  fi
  echo "Finished database setup"
}

if [ "$SERVER_NAME" = "web" ]; then
  setup_database;
fi

exec "$@"
