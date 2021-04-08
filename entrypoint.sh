#!/bin/bash
echo "$(date) - running DB and start scripts"

# Wait until Postgres is ready
while ! pg_isready -q -h $POSTGRES_HOSTNAME -p 5432 -U $POSTGRES_USER
do
  echo "$(date) - waiting for database to start"
  sleep 2
done

# Create, migrate, and seed database if it doesn't exist.
mix ecto.setup
echo "$(date) - database $POSTGRES_DB created."
exec mix phx.server
