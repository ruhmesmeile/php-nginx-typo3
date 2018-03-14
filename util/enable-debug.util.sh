#!/usr/bin/env bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
# set -x # Uncomment for debugging

pecl install -f xdebug-2.5.0;
docker-php-ext-enable xdebug;

if [ -z "$XDEBUG_REMOTE_HOST" ]; then
  echo "xdebug.remote_host=$XDEBUG_REMOTE_HOST" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini;
else
  echo "xdebug.remote_host=127.0.0.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini;
fi

if [ -z "$XDEBUG_REMOTE_PORT" ]; then
  echo "xdebug.remote_port=$XDEBUG_REMOTE_PORT" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini;
else
  echo "xdebug.remote_host=127.0.0.1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini;
fi

echo "xdebug.max_nesting_level=500" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini;
echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini;

service php-fpm restart;

apt-get update;
apt-get --yes install gdb strace;

docker-image-cleanup;



=192.168.100.172
XDEBUG_REMOTE_PORT=9000
XDEBUG_REMOTE_CONNECT_BACK=0