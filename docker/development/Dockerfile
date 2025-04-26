# =================================================================
# Final Stage: Development image
# =================================================================
FROM serversideup/php:8.2-fpm-nginx

USER root

RUN install-php-extensions intl \
  && apt-get update \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Configure shell aliases
RUN echo "alias ll='ls -al'" >> ~/.bash_aliases && \
    echo "alias a='php artisan'" >> ~/.bash_aliases && \
    echo "alias logs='tail -f storage/logs/laravel.log'" >> ~/.bash_aliases

USER www-data
