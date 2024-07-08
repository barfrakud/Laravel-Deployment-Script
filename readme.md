# Laravel Deployment Script

This bash script automates the deployment process for a Laravel application after pulling changes from Git. It performs necessary tasks to prepare the application for production use.

## Features

- Updates Composer dependencies
- Installs and builds npm assets
- Clears and rebuilds Laravel caches
- Runs database migrations
- Optimizes Laravel for production
- Sets proper file and directory permissions

## Prerequisites

- Access to a Unix-like environment (Linux, macOS, WSL)
- Git installed and configured
- Composer installed globally
- Node.js and npm installed
- Appropriate permissions to run the script and modify files

## Usage

1. Place the `deploy.sh` script in your Laravel project's root directory.

2. Make the script executable:
```chmod +x deploy.sh```

3. After pulling changes from Git, run the script:
```./deploy.sh```

## Customization

Adjust the chown command to use the appropriate web server user and group for your system (e.g., www-data:www-data, apache:apache, nginx:nginx).
Uncomment and modify the web server restart commands as needed for your setup.
Add or remove steps as required for your specific deployment process.

## Important Notes

This script assumes it's being run with sufficient permissions. You may need to use sudo for some commands.
Always test the deployment process in a staging environment before using it in production.
Ensure you have a recent backup of your application and database before deploying.
The script uses the --force flag for migrations, which will run them without prompting. Be cautious when there are pending migrations.

## Security

Review and understand each command in the script before using it.
Ensure that sensitive operations are properly secured and that the script is not accessible to unauthorized users.

## Contributing
Feel free to fork this script and adapt it to your needs. If you have suggestions for improvements, please open an issue or submit a pull request.

## License
This script is open-source and free to use. Please use responsibly.

