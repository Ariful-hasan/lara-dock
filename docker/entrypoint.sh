#!/bin/sh
set -e

echo "Running API optimizations..."
php artisan config:cache
php artisan route:cache

# Wait for the database service to be fully responsive to PHP
echo "Waiting for database connection..."
until php -r "try { new PDO('mysql:host=db;dbname=' . getenv('DB_DATABASE'), getenv('DB_USERNAME'), getenv('DB_PASSWORD')); exit(0); } catch (Exception \$e) { exit(1); }"; do
  echo "Database is unavailable - sleeping..."
  sleep 2
done

echo "Database is ready!"

echo "Running migrations..."
php artisan migrate --force

exec "$@"
