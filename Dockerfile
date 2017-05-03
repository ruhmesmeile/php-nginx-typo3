FROM webdevops/php-nginx:ubuntu-16.04

RUN mkdir -p /web/
WORKDIR /web/

# Configure PHP FPM
COPY config/php/php.ini /opt/docker/etc/php/php.ini
COPY config/php/application.conf /etc/php/7.0/fpm/pool.d/application.conf
COPY config/php/99-docker.php.ini /etc/php/7.0/fpm/conf.d/99-docker.ini

# Configure Nginx
COPY config/nginx/vhost.conf /opt/docker/etc/nginx/vhost.conf
COPY config/nginx/09-fpm.conf /opt/docker/etc/nginx/vhost.common.d/09-fpm.conf 

# Configure cronjob
COPY config/cron/crontab /etc/cron.d/typo3
COPY config/cron/cron.conf /opt/docker/etc/supervisor.d/cron.conf

RUN /usr/local/bin/apt-install mysql-client-5.7 \
    && docker-image-cleanup

RUN adduser www-data application
RUN chmod 0644 /etc/cron.d/typo3
