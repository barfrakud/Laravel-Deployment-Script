#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Print each command before executing it
set -x

# Update Composer dependencies
composer install --no-dev --optimize-autoloader

# Install npm dependencies
npm ci

# Build assets
npm run build

# Clear all Laravel caches
php artisan cache:clear
php artisan config:clear
php artisan route:clear
php artisan view:clear

# Restart the queue worker
php artisan queue:restart

# Run database migrations
php artisan migrate --force

# Optimize Laravel
php artisan optimize

# Update application cache
php artisan config:cache
php artisan route:cache
php artisan view:cache

# Set proper permissions (adjust as needed)
# Needs adjustment - not ready
#chown -R www:www .
#find . -type f -exec chmod 644 {} \;
#find . -type d -exec chmod 755 {} \;

# Restart your web server (uncomment and adjust as needed)
# sudo service nginx restart
# sudo service php8.1-fpm restart  # Adjust PHP version as necessary

echo "Deployment completed successfully!"
