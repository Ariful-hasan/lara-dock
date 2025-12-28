# STAGE 1: PHP Dependencies
FROM composer:2 AS vendor
WORKDIR /app
# We copy from the root's code perspective
COPY composer.json composer.lock ./
RUN composer install --optimize-autoloader --no-interaction --no-scripts

# STAGE 2: Final Production Image
FROM php:8.4-fpm-alpine
WORKDIR /var/www/html

# 1. Define arguments for your local user (defaults to empty for prod)
ARG USER_ID
ARG GROUP_ID

# 2. Install system tools (allow us to modify existing users, fcgi for healthcheck)
RUN apk add --no-cache shadow fcgi

# 3. If USER_ID is passed, change www-data's ID to match yours
# This ensures permissions align with your local host machine
RUN if [ ! -z "$USER_ID" ]; then \
        usermod -u $USER_ID www-data && \
        groupmod -g $GROUP_ID www-data; \
    fi

# 4. Install PHP extensions for a modern Laravel API
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pdo_mysql bcmath gd zip intl mbstring redis

# 5. Copy PHP config
COPY docker/php/php.ini /usr/local/etc/php/conf.d/php.ini
COPY docker/php/www.conf /usr/local/etc/php-fpm.d/www.conf

# 6. Copy Code with Permissions (The "One-Shot" method)
# This handles the owner for EVERYTHING copied in
COPY --chown=www-data:www-data . .
COPY --chown=www-data:www-data --from=vendor /app/vendor ./vendor

# 6. Setup Entrypoint
COPY docker/entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

USER www-data
ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]
