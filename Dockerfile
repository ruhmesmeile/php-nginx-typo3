FROM webdevops/php-nginx:7.1

# Add application dir
RUN mkdir -p /app/
WORKDIR /app/

# Add directory for PHP socket
RUN mkdir -p /var/run/php

# Configure PHP
COPY config/php/99-docker.php.ini /usr/local/etc/php/conf.d/99-docker.ini

# Configure PHP FPM
COPY config/php/application.conf /usr/local/etc/php-fpm.d/application.conf

# Install APCu / APC backwards compatibility
COPY bin/apc.so /tmp/apc.so
RUN mv /tmp/apc.so $(php -r "echo ini_get('extension_dir');")/apc.so \
  && echo "extension=apc.so" | tee /opt/docker/etc/php/apcu-bc.ini \
  && ln -sf /opt/docker/etc/php/apcu-bc.ini /usr/local/etc/php/conf.d/30-apcu-bc.ini

# Configure Blackfire
COPY config/php/97-blackfire.php.ini /opt/docker/etc/php/blackfire.ini
RUN version=$(php -r "echo PHP_MAJOR_VERSION.PHP_MINOR_VERSION;") \
  && curl -A "Docker" -o /tmp/blackfire-probe.tar.gz -D - -L -s https://blackfire.io/api/v1/releases/probe/php/linux/amd64/$version \
  && tar zxpf /tmp/blackfire-probe.tar.gz -C /tmp \
  && mv /tmp/blackfire-*.so $(php -r "echo ini_get('extension_dir');")/blackfire.so \
  && ln -sf /opt/docker/etc/php/blackfire.ini /usr/local/etc/php/conf.d/97-blackfire.ini \
  && chown root:root $(php -r "echo ini_get('extension_dir');")/blackfire.so

# Configure Nginx
COPY config/nginx/mime.types /etc/nginx/mime.types
COPY config/nginx/fastcgi_params /etc/nginx/fastcgi_params
COPY config/nginx/nginx.conf /etc/nginx/nginx.conf
COPY config/nginx/vhost.conf /opt/docker/etc/nginx/vhost.conf
RUN rm -f /opt/docker/etc/nginx/vhost.common.d/*
COPY config/nginx/vhost.common.d /opt/docker/etc/nginx/vhost.common.d

# Configure cronjob
COPY config/cron/crontab /etc/cron.d/typo3
COPY config/cron/cron.conf /opt/docker/etc/supervisor.d/cron.conf

# Install current Nginx
RUN echo "deb http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list \
  && echo "deb-src http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list \
  && curl http://nginx.org/keys/nginx_signing.key > /tmp/nginx_signing.key \
  && apt-key add /tmp/nginx_signing.key \
  && apt-get update \
  && apt-get --assume-yes install nginx

# Install MySQL client
RUN echo "deb http://repo.mysql.com/apt/debian jessie mysql-5.7" >> /etc/apt/sources.list \
  && gpg --recv-keys 5072E1F5 || true \
  && sleep 1s \
  && gpg --recv-keys 5072E1F5 \
  && gpg --export 5072E1F5 > /etc/apt/trusted.gpg.d/5072E1F5.gpg \
  && apt-get update \
  && apt-get --assume-yes install mysql-client \
  && docker-image-cleanup

# Add user and fix permissions
RUN adduser www-data application
RUN chmod 0644 /etc/cron.d/typo3
