#!/usr/bin/env bash
set -e

echo "Starting 11-setup-laravel.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

if cp .env.prod .env; then
    echo $GREEN ".env created from .env.prod successfully"
else
    echo $RED "Failed to create .env from .env.prod"
    exit 1
fi

php artisan optimize:clear
php artisan filament:optimize-clear
php artisan optimize
php artisan filament:optimize
php artisan storage:link

echo $YELLOW "Waiting for MySQL to be ready at mysql:3306..."
# netcat-openbsd هست که چک میکنه آیا پورت باز است یا خیر
while ! nc -z "mysql" "3306"; do
  sleep 1
done
echo $GREEN "MySQL is ready!"

php artisan migrate --force

echo $GREEN "11-setup-laravel.sh executed successfully."
