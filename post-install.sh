#!/bin/bash
set -e

echo "=========================================="
echo "  osTicket Post-Installation Hardening"
echo "=========================================="

OST_CONFIG="/var/www/html/include/ost-config.php"
SETUP_DIR="/var/www/html/setup"

# Secure ost-config.php - remove write access
if [ -f "$OST_CONFIG" ]; then
    chmod 644 "$OST_CONFIG"
    chown www-data:www-data "$OST_CONFIG"
    echo "[OK] Secured ost-config.php (mode 644)"
else
    echo "[WARN] ost-config.php not found at $OST_CONFIG"
fi

# Remove setup directory for security
if [ -d "$SETUP_DIR" ]; then
    rm -rf "$SETUP_DIR"
    echo "[OK] Removed setup directory"
else
    echo "[WARN] Setup directory not found at $SETUP_DIR"
fi

# Set proper permissions for key directories
for dir in imagesupload scp attachments; do
    if [ -d "/var/www/html/$dir" ]; then
        chmod -R 755 "/var/www/html/$dir"
        echo "[OK] Secured $dir directory"
    fi
done

echo "=========================================="
echo "  Hardening Complete!"
echo "=========================================="

exec "$@"