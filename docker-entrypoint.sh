#!/bin/bash
set -e

echo "=========================================="
echo "  osTicket Docker Container Startup"
echo "=========================================="

# Create upload directory if it doesn't exist
if [ ! -d "/var/www/html/upload" ]; then
    mkdir -p /var/www/html/upload
    echo "Created upload directory"
fi

# Set proper permissions
chown -R www-data:www-data /var/www/html/upload
chmod -R 775 /var/www/html/upload

# Create ost-config.php from sample if it doesn't exist
if [ ! -f "/var/www/html/include/ost-config.php" ]; then
    if [ -f "/var/www/html/include/ost-sampleconfig.php" ]; then
        cp /var/www/html/include/ost-sampleconfig.php /var/www/html/include/ost-config.php
        chown www-data:www-data /var/www/html/include/ost-config.php
        chmod 640 /var/www/html/include/ost-config.php
        echo "Created ost-config.php from sample"
    fi
fi

# Ensure key directories are writable
for dir in imagesupload scp attachments; do
    if [ -d "/var/www/html/$dir" ]; then
        chmod -R 777 "/var/www/html/$dir"
        chown -R www-data:www-data "/var/www/html/$dir"
        echo "Set permissions for $dir"
    fi
done

# Set session directory if needed
if [ ! -d "/var/www/html/include/tmp" ]; then
    mkdir -p /var/www/html/include/tmp
    chmod -R 777 /var/www/html/include/tmp
fi

echo "=========================================="
echo "  Starting Apache..."
echo "=========================================="

exec apache2-foreground