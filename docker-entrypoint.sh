#!/bin/bash
set -e

DB_HOST="${DB_HOST:-db}"
DB_PORT="${DB_PORT:-3306}"
DB_USER="${DB_USER:-root}"
DB_PASS="${DB_PASS:-hms_password}"
DB_NAME="${DB_NAME:-hms}"

echo "HMS Docker: Waiting for MySQL at ${DB_HOST}:${DB_PORT}..."
until mysqladmin ping -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" --silent 2>/dev/null; do
    echo "HMS Docker: MySQL not ready yet, retrying in 2s..."
    sleep 2
done
echo "HMS Docker: MySQL is ready!"

# Check if database exists, if not import schema
DB_EXISTS=$(mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" -N -e "SELECT SCHEMA_NAME FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME='$DB_NAME'" 2>/dev/null)
if [ -z "$DB_EXISTS" ]; then
    echo "HMS Docker: Database '${DB_NAME}' not found. Creating and importing schema..."
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" -e "CREATE DATABASE IF NOT EXISTS \`$DB_NAME\` CHARACTER SET utf8 COLLATE utf8_general_ci;"
    mysql -h"$DB_HOST" -P"$DB_PORT" -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" < /var/www/html/uploads/hms.sql
    echo "HMS Docker: Schema imported successfully!"
else
    echo "HMS Docker: Database '${DB_NAME}' already exists. Skipping import."
fi

# Update database.php with Docker environment values
sed -i "s/\$db\['default'\]\['hostname'\] = '.*'/\$db['default']['hostname'] = '${DB_HOST}'/" /var/www/html/application/config/database.php
sed -i "s/\$db\['default'\]\['username'\] = '.*'/\$db['default']['username'] = '${DB_USER}'/" /var/www/html/application/config/database.php
sed -i "s/\$db\['default'\]\['password'\] = '.*'/\$db['default']['password'] = '${DB_PASS}'/" /var/www/html/application/config/database.php
sed -i "s/\$db\['default'\]\['database'\] = '.*'/\$db['default']['database'] = '${DB_NAME}'/" /var/www/html/application/config/database.php

echo "HMS Docker: Database configuration updated."

exec "$@"
