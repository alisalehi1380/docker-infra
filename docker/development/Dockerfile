# =================================================================
# Final Stage: Development image
# =================================================================
FROM serversideup/php:8.2-fpm-nginx

USER root

# mariadb-client برای spatie-backup استفاده میشه
RUN install-php-extensions intl \
  && apt-get update \
  && apt-get install -y mariadb-client \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Configure shell aliases
RUN echo "alias ll='ls -al'" >> /etc/bash.bashrc && \
    echo "alias a='php artisan'" >> /etc/bash.bashrc && \
    echo "alias logs='tail -n 100 -f storage/logs/laravel.log'" >> /etc/bash.bashrc

USER www-data
