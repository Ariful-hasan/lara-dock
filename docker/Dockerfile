# STAGE 1: PHP Dependencies
FROM composer:2 AS vendor
WORKDIR /app
# We copy from the root's code perspective
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader --no-interaction --no-scripts

# STAGE 2: Final Production Image
FROM php:8.4-fpm-alpine
WORKDIR /var/www/html

# 1. Define arguments for your local user (defaults to empty for prod)
ARG USER_ID
ARG GROUP_ID

# 2. Install 'shadow' to allow us to modify existing users in Alpine
RUN apk add --no-cache shadow

# 3. If USER_ID is passed, change www-data's ID to match yours
# This ensures permissions align with your local host machine
RUN if [ ! -z "$USER_ID" ]; then \
        usermod -u $USER_ID www-data && \
        groupmod -g $GROUP_ID www-data; \
    fi

# 4. Install PHP extensions for a modern Laravel API
COPY --from=mlocati/php-extension-installer /usr/bin/install-php-extensions /usr/local/bin/
RUN install-php-extensions pdo_mysql bcmath gd zip intl opcache mbstring \
    && apk add --no-cache fcgi

# 5. Copy Code with Permissions (The "One-Shot" method)
# This handles the owner for EVERYTHING copied in
COPY --chown=www-data:www-data . .
COPY --chown=www-data:www-data --from=vendor /app/vendor ./vendor

# 2. Prepare Directories & Permissions (Do this BEFORE copying code)
# This creates the folders and sets owner so the layer can be cached
# can be ignored this step if --chown=www-data:www-data is used in COPY command
# RUN mkdir -p storage/framework/sessions storage/framework/views storage/framework/cache bootstrap/cache \
#     && chown -R www-data:www-data /var/www/html

# 6. Setup Entrypoint
COPY docker/entrypoint.sh /usr/local/bin/docker-entrypoint
RUN chmod +x /usr/local/bin/docker-entrypoint

# 4. Copy application code (Only changes here will bust the cache from this point down)
# COPY . .
# COPY --from=vendor /app/vendor ./vendor



# 5. Finalize permissions for any new files copied in
# RUN chown -R www-data:www-data storage bootstrap/cache

USER www-data
ENTRYPOINT ["docker-entrypoint"]
CMD ["php-fpm"]
