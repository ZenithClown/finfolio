#!/bin/bash

# Script to Start the PostgreSQL REST API using PostgREST
# Use the Credentials from Environment Variables ~/.zshrc_credentials

if [ -z "$ORACLE_POSTGRES_USERNAME" ] || [ -z "$ORACLE_POSTGRES_PASSWORD" ]; then
    echo "ERROR: Username and/or Password is not defined for Oracle PostgreSQL"
    exit 1
fi

if [ -z "$ORACLE_POSTGRES_HOST" ] || [ -z "$ORACLE_POSTGRES_PORT" ]; then
    echo "ERROR: Oracle PostgreSQL Host and/or Port is not defined"
    exit 1
fi

# Build the full Postgres connection URI
export PGRST_DB_URI="postgres://$ORACLE_POSTGRES_USERNAME:$ORACLE_POSTGRES_PASSWORD@$ORACLE_POSTGRES_HOST:$ORACLE_POSTGRES_PORT/finfolio"

echo "Starting PostgREST with DB URI:"
echo "$PGRST_DB_URI" | sed 's/:\(.*\)@/:****@/'  # Mask password in output

# Start PostgREST with the config file
postgrest postgrest.conf
