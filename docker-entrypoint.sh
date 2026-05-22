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

# Substitute environment variables into ost-config.php
if [ -f "/var/www/html/include/ost-config.php" ]; then
    sed -i "s|%CONFIG-DBHOST|${DB_HOST:-osticket-db}|g" /var/www/html/include/ost-config.php
    sed -i "s|%CONFIG-DBNAME|${DB_NAME:-osticket}|g" /var/www/html/include/ost-config.php
    sed -i "s|%CONFIG-DBUSER|${DB_USER:-osticket}|g" /var/www/html/include/ost-config.php
    sed -i "s|%CONFIG-DBPASS|${DB_PASSWORD:-osticket_pass}|g" /var/www/html/include/ost-config.php
    sed -i "s|%CONFIG-PREFIX|${TABLE_PREFIX:-ost_}|g" /var/www/html/include/ost-config.php
    sed -i "s|%CONFIG-SIRI|$(openssl rand -hex 32 2>/dev/null || echo 'changeme123456789')|g" /var/www/html/include/ost-config.php
    sed -i "s|%ADMIN-EMAIL|${ADMIN_EMAIL:-admin@localhost}|g" /var/www/html/include/ost-config.php
    # Mark osTicket as installed when DB credentials are properly configured
    sed -i "s/define('OSTINSTALLED',FALSE)/define('OSTINSTALLED',TRUE)/g" /var/www/html/include/ost-config.php
    echo "Substituted environment variables into ost-config.php"
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

# Post-installation hardening
OST_CONFIG="/var/www/html/include/ost-config.php"
SETUP_DIR="/var/www/html/setup"

# Check if osTicket is fully installed (OSTINSTALLED is TRUE, meaning web installer completed)
# Only remove setup if osTicket has been fully installed through the web installer
if [ -f "$OST_CONFIG" ] && grep -q "define('OSTINSTALLED',TRUE)" "$OST_CONFIG" 2>/dev/null; then
    echo "=========================================="
    echo "  Post-Installation Hardening"
    echo "=========================================="

    # Secure ost-config.php - remove world-write (keep 640 for www-data read)
    chmod 640 "$OST_CONFIG"
    chown www-data:www-data "$OST_CONFIG"
    echo "[OK] Secured ost-config.php (mode 640)"

    # Remove setup directory for security
    if [ -d "$SETUP_DIR" ]; then
        rm -rf "$SETUP_DIR"
        echo "[OK] Removed setup directory"
    fi

    echo "=========================================="
    echo "  Hardening Complete!"
    echo "=========================================="
fi

echo "=========================================="
echo "  Starting Apache..."
echo "=========================================="

exec apache2-foreground