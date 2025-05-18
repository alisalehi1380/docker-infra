# =================================================================
# Stage 1: Composer dependencies
# =================================================================
FROM serversideup/php:8.2-fpm-nginx AS base

USER root

RUN install-php-extensions intl exif

COPY composer.json composer.lock ./
RUN composer install --no-plugins --no-scripts --no-interaction --no-progress --optimize-autoloader

COPY --chmod=755 docker/entrypoint.d /etc/entrypoint.d
COPY --chmod=755 docker/services /etc/services.d
COPY --chown=www-data:www-data . .
RUN chmod -R 755 . && chmod +x /etc/services.d/*

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
FROM serversideup/php:8.2-fpm-nginx AS production

USER root

# mariadb-client برای spatie-backup استفاده میشه
RUN install-php-extensions intl \
  && apt-get update \
  && apt-get install -y mariadb-client netcat-openbsd iputils-ping \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

COPY --from=static-assets app/public/build ./public/build
COPY --from=base var/www/html .
COPY --from=base /etc/entrypoint.d /etc/entrypoint.d
COPY --from=base /etc/services.d /etc/services.d

RUN composer dump-autoload --optimize \
    && chmod -R u+rwX,go-w storage bootstrap/cache

# Add useful shell aliases
RUN echo "alias ll='ls -al'" >> /etc/bash.bashrc && \
    echo "alias a='php artisan'" >> /etc/bash.bashrc && \
    echo "alias logs='tail -n 100 -f storage/logs/laravel.log'" >> /etc/bash.bashrc && \
    echo "alias amfs='a migrate:fresh --seed'" >> /etc/bash.bashrc

USER www-data

# =================================================================
# Development image
# =================================================================
FROM serversideup/php:8.2-fpm-nginx AS development

USER root

# mariadb-client برای spatie-backup استفاده میشه
RUN install-php-extensions intl exif \
  && apt-get update \
  && apt-get install -y mariadb-client iputils-ping curl gnupg \
  && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Configure shell aliases
RUN echo "alias ll='ls -al'" >> /etc/bash.bashrc && \
    echo "alias a='php artisan'" >> /etc/bash.bashrc && \
    echo "alias logs='tail -n 100 -f storage/logs/laravel.log'" >> /etc/bash.bashrc && \
    echo "alias amfs='a migrate:fresh --seed'" >> /etc/bash.bashrc && \
    echo "alias aoclear='a optimize:clear'" >> /etc/bash.bashrc

USER www-data