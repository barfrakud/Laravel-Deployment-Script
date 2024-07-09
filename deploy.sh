#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Print each command before executing it
set -x

# Verify Laravel requirements
# Check PHP version is at least 8.2
REQUIRED_PHP_VERSION="8.2"
PHP_VERSION=$(php -r "echo PHP_VERSION;")

version_compare() {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# Use the version_compare function
version_compare "$PHP_VERSION" "$REQUIRED_PHP_VERSION"
compare_result=$?

if [ $compare_result -eq 1 ] || [ $compare_result -eq 0 ]; then
    echo "PHP version is $PHP_VERSION - OK (meets or exceeds required version $REQUIRED_PHP_VERSION)"
else
    echo "PHP version is $PHP_VERSION - FAIL (requires $REQUIRED_PHP_VERSION or higher)"
    exit 1
fi

# Check PHP extensions
REQUIRED_EXTENSIONS=("ctype" "curl" "dom" "fileinfo" "filter" "hash" "mbstring" "openssl" "pcre" "pdo" "session" "tokenizer" "xml")

for EXTENSION in "${REQUIRED_EXTENSIONS[@]}"; do
    if php -m | grep -q "$EXTENSION"; then
        echo "PHP extension $EXTENSION - OK"
    else
        echo "PHP extension $EXTENSION - FAIL"
        exit 1
    fi
done
echo "All requirements are met. You can run Laravel 11 on this server."

# Verify Laravel .env file
# Define the environment variable names to check
ENV_VARS=("APP_ENV" "APP_DEBUG")

# Check if .env file exists
if [ -f .env ]; then
    # Loop through each environment variable
    for var in "${ENV_VARS[@]}"; do
        # Get the value of the variable from .env file
        value_env=$(grep -E "^$var=" .env | cut -d= -f2)
        
        # Compare the values
        if [[ "$var" == "APP_ENV" ]]; then
            if [ "$value_env" = "production" ]; then
                echo "$var is set correctly in .env file."
            else
                echo "Error: $var is not set correctly in .env file. Expected value: production"
            fi
        elif [[ "$var" == "APP_DEBUG" ]]; then
            if [ "$value_env" = "false" ]; then
                echo "$var is set correctly in .env file."
            else
                echo "Error: $var is not set correctly in .env file. Expected value: false"
            fi
        fi
    done
else
    echo "Error: .env file not found."
fi


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

# Directory permissions
# Laravel will need to write to the bootstrap/cache and storage directories, so you should ensure the web server process owner has permission to write to these directories.
# Set the permissions of the bootstrap/cache and storage directories to 0777.
# bootstrap/cache
# storage
sudo chmod -R 0777 bootstrap/cache storage



# Restart your web server (uncomment and adjust as needed)
# sudo service nginx restart
# sudo service php8.1-fpm restart  # Adjust PHP version as necessary

echo "Deployment completed successfully!"
