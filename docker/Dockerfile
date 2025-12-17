ARG REGISTRY

# =================================================================
# Stage 0: Base PHP Image with Extensions
#
# workdir is /var/www/html
# =================================================================
FROM ${REGISTRY}/serversideup/php:8.2-fpm-nginx AS php-base

USER root

RUN install-php-extensions intl exif soap


# =================================================================
# Stage 1: Install Composer Dependencies
#
# workdir is /var/www/html
# =================================================================
FROM php-base AS vendor

USER root

COPY composer.json composer.lock ./
COPY app/Support/Helpers ./app/Support/Helpers

# copy modules
COPY Modules ./Modules

RUN composer install \
    --no-interaction \
    --no-progress \
    --prefer-dist \
    --no-scripts \
    --no-autoloader


# =================================================================
# Stage 2: Frontend Assets Compilation
# =================================================================
FROM ${REGISTRY}/node:20 AS static-assets

WORKDIR /app

COPY package*.json vite.config.js postcss.config.js ./

RUN npm ci --no-audit --no-fund

COPY --from=vendor /var/www/html/vendor ./vendor
COPY resources ./resources
COPY public ./public

RUN npm run build


# =================================================================
# Stage 3: Production Image
#
# workdir is /var/www/html
# =================================================================
FROM php-base AS production

USER root

# mariadb-client | for Spatie Backup
RUN apt-get update && \
    apt-get install -y \
        mariadb-client \
        netcat-openbsd \
        iputils-ping && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --chmod=755 --chown=www-data:www-data docker/entrypoint.d /etc/entrypoint.d
COPY --chmod=755 --chown=www-data:www-data docker/services /etc/services.d
COPY docker/nginx/nginx.conf.template /etc/nginx/nginx.conf.template

## Copy composer files
COPY --chmod=755 --chown=www-data:www-data composer.json composer.lock ./
COPY --from=vendor --chown=www-data:www-data /var/www/html/vendor ./vendor

## Copy npm build files
COPY --from=static-assets --chown=www-data:www-data /app/public/build ./public/build

## Copy application source code
COPY --chmod=755 --chown=www-data:www-data app ./app
COPY --chmod=755 --chown=www-data:www-data bootstrap ./bootstrap
COPY --chmod=755 --chown=www-data:www-data config ./config
COPY --chmod=755 --chown=www-data:www-data database ./database
COPY --chmod=755 --chown=www-data:www-data docker ./docker
COPY --chmod=755 --chown=www-data:www-data lang ./lang
COPY --chmod=755 --chown=www-data:www-data public ./public
COPY --chmod=755 --chown=www-data:www-data routes ./routes
COPY --chmod=755 --chown=www-data:www-data storage ./storage
COPY --chmod=755 --chown=www-data:www-data docs ./docs
COPY --chmod=755 --chown=www-data:www-data resources/views ./resources/views

# copy Modules
COPY --chmod=755 --chown=www-data:www-data Modules ./Modules
COPY --chmod=755 --chown=www-data:www-data modules_statuses.json artisan ./

# copy public directories
COPY --chmod=755 --chown=www-data:www-data public/css ./public/css
COPY --chmod=755 --chown=www-data:www-data public/fonts ./public/fonts
COPY --chmod=755 --chown=www-data:www-data public/js ./public/js
COPY --chmod=755 --chown=www-data:www-data public/index.php public/robots.txt ./

RUN ls -la .
RUN ls -la ./Modules

RUN composer dump-autoload --optimize --classmap-authoritative \
 && chown -R www-data:www-data storage bootstrap/cache /var/log/nginx \
 && chmod -R u+rwX,go-w storage bootstrap/cache \
 && chmod +x /etc/services.d/*

# Add useful shell aliases
RUN echo "alias ll='ls -al'" >> /etc/bash.bashrc && \
    echo "alias a='php artisan'" >> /etc/bash.bashrc && \
    echo "alias logs='tail -n 100 -f storage/logs/laravel.log'" >> /etc/bash.bashrc && \
    echo "alias ads='a db:seed'" >> /etc/bash.bashrc

USER www-data


# =================================================================
# Development image
# =================================================================
FROM ${REGISTRY}/serversideup/php:8.2-fpm-nginx AS development

USER root

# mariadb-client | for Spatie Backup
RUN install-php-extensions intl exif soap xdebug \
  && apt-get update \
  && apt-get install -y \
    mariadb-client \
    iputils-ping \
    curl gnupg \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN echo "xdebug.mode=coverage" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

# Configure shell aliases
RUN echo "alias ll='ls -al'" >> /etc/bash.bashrc && \
    echo "alias a='php artisan'" >> /etc/bash.bashrc && \
    echo "alias c='composer'" >> /etc/bash.bashrc && \
    \
    echo "alias logs='tail -n 100 -f storage/logs/laravel.log'" >> /etc/bash.bashrc && \
    echo "alias amfs='a migrate:fresh --seed'" >> /etc/bash.bashrc && \
    echo "alias aoc='a optimize:clear'" >> /etc/bash.bashrc && \
    \
    echo "alias am:fi-r='a make:filament-resource'" >> /etc/bash.bashrc && \
    echo "alias am:fi-rm='a make:filament-relation-manager'" >> /etc/bash.bashrc && \
    echo "alias am:fi-w='a make:filament-widget'" >> /etc/bash.bashrc

USER www-data
