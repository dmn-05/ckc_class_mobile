FROM php:8.2-apache

RUN apt-get update \
    && apt-get install -y --no-install-recommends libcurl4-openssl-dev libzip-dev unzip \
    && docker-php-ext-install curl mysqli pdo_mysql zip \
    && rm -rf /var/lib/apt/lists/*

COPY backend/ /var/www/html/backend/

RUN chown -R www-data:www-data /var/www/html/backend

CMD ["sh", "-c", "sed -i \"s/Listen 80/Listen ${PORT:-80}/\" /etc/apache2/ports.conf && sed -i \"s/:80>/:${PORT:-80}>/\" /etc/apache2/sites-available/000-default.conf && apache2-foreground"]
