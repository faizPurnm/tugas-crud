FROM php:8.2-apache

# Ekstensi yang dibutuhkan backend: PDO MySQL dan cURL untuk importer DummyJSON.
RUN apt-get update \
    && apt-get install -y --no-install-recommends libcurl4-openssl-dev \
    && docker-php-ext-install pdo_mysql curl \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Backend tetap berada di /backend agar URL API konsisten dengan project Flutter.
COPY . /var/www/html/backend/

# Izinkan .htaccess mengatur rewrite endpoint REST API.
RUN printf '%s\n' \
    '<Directory /var/www/html/backend>' \
    '    AllowOverride All' \
    '    Require all granted' \
    '</Directory>' \
    > /etc/apache2/conf-available/backend-override.conf \
    && a2enconf backend-override \
    && chown -R www-data:www-data /var/www/html/backend

EXPOSE 80
