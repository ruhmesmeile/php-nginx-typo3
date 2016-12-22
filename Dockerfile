FROM ruhmesmeile/php-nginx:ubuntu-16.04

RUN mkdir -p /web/
WORKDIR /web/

COPY config/99-docker.php.ini /etc/php/7.0/fpm/conf.d/99-docker.ini
COPY config/vhost.conf /opt/docker/etc/nginx/vhost.conf
COPY config/application.conf /etc/php/7.0/fpm/pool.d/application.conf 
COPY config/09-fpm.conf /opt/docker/etc/nginx/vhost.common.d/09-fpm.conf 
