# =================================================================
# Stage 1: Composer dependencies
# =================================================================
FROM serversideup/php:8.2-fpm-nginx AS base

USER root

RUN install-php-extensions intl \
  && apt-get update \
  && apt-get install -y netcat-openbsd iputils-ping nano \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY composer.json composer.lock ./
RUN composer install --no-plugins --no-scripts --no-interaction --no-progress --optimize-autoloader

COPY --chmod=755 docker/production/entrypoint.d /etc/entrypoint.d
COPY --chmod=755 docker/production/services /etc/services.d
COPY --chown=www-data:www-data . .
RUN chmod -R 755 /var/www/html

RUN chmod +x /etc/services.d/*

# =================================================================
# Stage 2: Frontend assets compilation
# =================================================================
FROM node:20 AS static-assets

WORKDIR /app

COPY package*.json vite.config.js ./
RUN npm ci --no-audit --no-fund

COPY --chown=www-data:www-data . .

RUN npm run build


# =================================================================
# Final Stage: Production image
# =================================================================
FROM serversideup/php:8.2-fpm-nginx

LABEL author="Ali Salehi"
LABEL email="alisalehi.dev@gmail.com"

USER root

# mariadb-client برای spatie-backup استفاده میشه
RUN install-php-extensions intl \
  && apt-get update \
  && apt-get install -y mariadb-client netcat-openbsd iputils-ping \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=static-assets app/public/build /public/build
COPY --from=base var/www/html/ /var/www/html

COPY --from=base /etc/entrypoint.d /etc/entrypoint.d
COPY --from=base /etc/services.d /etc/services.d

RUN composer dump-autoload

# Configure shell aliases
RUN echo "alias ll='ls -al'" >> /etc/bash.bashrc && \
    echo "alias a='php artisan'" >> /etc/bash.bashrc && \
    echo "alias logs='tail -n 100 -f storage/logs/laravel.log'" >> /etc/bash.bashrc

USER www-data
