#!/bin/bash
set -e

echo "Starting 11-setup-laravel.sh"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'

if [ ! -f .env.prod ]; then
    echo $RED ".env.prod file not found!"
    exit 1
fi
cp .env.prod .env

if ! grep -q '^APP_KEY=' .env || grep -q '^APP_KEY=$' .env; then
    php artisan key:generate
    echo $GREEN "Generating Laravel application key successfully"
else
    echo $YELLOW "APP_KEY is already set."
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
