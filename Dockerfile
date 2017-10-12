FROM webdevops/php-nginx-dev:ubuntu-16.04

# Add application dir
RUN mkdir -p /app/
WORKDIR /app/

# Configure PHP
COPY config/php/99-docker.php.ini /etc/php/7.0/fpm/conf.d/99-docker.ini

# Configure PHP FPM
COPY config/php/application.conf /etc/php/7.0/fpm/pool.d/application.conf

# Install APCu / APC backwards compatibility
COPY bin/apc.so /tmp/apc.so
RUN mv /tmp/apc.so $(php -r "echo ini_get('extension_dir');")/apc.so \
  && echo "extension=apc.so" | tee /etc/php/7.0/mods-available/apcu-bc.ini \
  && ln -sf /etc/php/7.0/mods-available/apcu-bc.ini /etc/php/7.0/fpm/conf.d/30-apcu-bc.ini \
  && ln -sf /etc/php/7.0/mods-available/apcu-bc.ini /etc/php/7.0/cli/conf.d/30-apcu-bc.ini

# Configure Blackfire
COPY config/php/97-blackfire.php.ini /etc/php/7.0/mods-available/blackfire.ini
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
  && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
  && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
  && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
  && ln -sf /etc/php/7.0/mods-available/blackfire.ini /etc/php/7.0/fpm/conf.d/97-blackfire.ini \
  && ln -sf /etc/php/7.0/mods-available/blackfire.ini /etc/php/7.0/cli/conf.d/97-blackfire.ini \
  && chown root:root $(php -r "echo ini_get('extension_dir');")/blackfire.so

# Configure Nginx
COPY config/nginx/vhost.conf /opt/docker/etc/nginx/vhost.conf
COPY config/nginx/09-fpm.conf /opt/docker/etc/nginx/vhost.common.d/09-fpm.conf 

# Configure cronjob
COPY config/cron/crontab /etc/cron.d/typo3
COPY config/cron/cron.conf /opt/docker/etc/supervisor.d/cron.conf

# Install MySQL client
RUN /usr/local/bin/apt-install mysql-client-5.7 \
    && docker-image-cleanup

# Add user and fix permissions
RUN adduser www-data application
RUN chmod 0644 /etc/cron.d/typo3
