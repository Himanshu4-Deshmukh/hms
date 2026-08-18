FROM php:7.4-apache

# Install MySQLi extension and useful tools
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    libzip-dev \
    unzip \
    default-mysql-client \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install -j$(nproc) gd mysqli \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# Enable Apache mod_rewrite
RUN a2enmod rewrite

# Set recommended PHP settings for CodeIgniter 2.x
RUN { \
    echo 'display_errors = On'; \
    echo 'error_reporting = E_ALL & ~E_NOTICE & ~E_STRICT & ~E_DEPRECATED'; \
    echo 'upload_max_filesize = 10M'; \
    echo 'post_max_size = 10M'; \
    echo 'max_execution_time = 300'; \
    echo 'memory_limit = 256M'; \
    echo 'short_open_tag = On'; \
    } > /usr/local/etc/php/conf.d/hms.ini

# Set working directory
WORKDIR /var/www/html

# Copy application files
COPY . /var/www/html/

# Copy entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set proper permissions for writable directories
RUN chown -R www-data:www-data /var/www/html/application/cache \
    /var/www/html/application/logs \
    /var/www/html/uploads \
    && chmod -R 775 /var/www/html/application/cache \
    /var/www/html/application/logs \
    /var/www/html/uploads

EXPOSE 80

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["apache2-foreground"]
