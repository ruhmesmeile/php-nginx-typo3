FROM webdevops/php-nginx:ubuntu-15.10

RUN mkdir -p /web/
WORKDIR /web/

# Configure PHP FPM
COPY config/php/php.ini /opt/docker/etc/php/php.ini
COPY config/php/application.conf /etc/php5/fpm/pool.d/application.conf 
COPY config/php/99-docker.php.ini /etc/php5/fpm/conf.d/99-docker.ini

# Configure Nginx
COPY config/nginx/vhost.conf /opt/docker/etc/nginx/vhost.conf
COPY config/nginx/09-fpm.conf /opt/docker/etc/nginx/vhost.common.d/09-fpm.conf 
