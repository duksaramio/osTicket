# osTicket Docker Image
# Based on official PHP Apache image

FROM php:8.4-apache

# Install system dependencies and PHP extensions
RUN apt-get update && apt-get install -y \
    libicu-dev \
    libzip-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
    libssl-dev \
    libmagickwand-dev \
    libonig-dev \
    ghostscript \
    unzip \
    git \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install -j$(nproc) \
    mysqli \
    pdo \
    pdo_mysql \
    gd \
    intl \
    zip \
    opcache \
    xml \
    mbstring \
    exif

# Install ImageMagick for PDF thumbnail generation
RUN pecl install imagick && docker-php-ext-enable imagick

# Enable Apache mod_rewrite (required for osTicket)
RUN a2enmod rewrite headers

# Set PHP upload settings for osTicket attachments
RUN echo "upload_max_filesize = 20M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 25M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "memory_limit = 256M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "max_execution_time = 300" >> /usr/local/etc/php/conf.d/uploads.ini

# Set working directory
WORKDIR /var/www/html

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Copy application files (excluding those from .dockerignore)
COPY . /var/www/html/

# Set proper permissions for osTicket
RUN chown -R www-data:www-data /var/www/html \
    && chmod -R 755 /var/www/html \
    && chmod -R 777 /var/www/html/include/ost-config.php 2>/dev/null || true \
    && chmod -R 777 /var/www/html/images/upload 2>/dev/null || true

# Expose ports
EXPOSE 80 443

# Use custom entrypoint
ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["apache2-foreground"]