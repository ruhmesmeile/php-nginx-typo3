#!/usr/bin/env bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
# set -x # Uncomment for debugging

cd /app

mysql -h $DBHOST -u $DBUSER -p"$DBPASS" -e "DROP DATABASE IF EXISTS $TYPO3__DB__Connections__Default__dbname; CREATE DATABASE $TYPO3__DB__Connections__Default__dbname;"
rm -f web/typo3conf/LocalConfiguration.php web/typo3conf/PackageStates.php
rm -rf web/typo3temp/*

mkdir -p private

vendor/bin/typo3cms install:setup --non-interactive --database-user-name $TYPO3__DB__Connections__Default__user --database-user-password $TYPO3__DB__Connections__Default__password --database-host-name $TYPO3__DB__Connections__Default__host --database-port 3306 --database-name $TYPO3__DB__Connections__Default__dbname --editor-user-name $editor_username --editor-password $editor_password --admin-user-name $admin_username --admin-password $admin_password
vendor/bin/typo3cms cache:flush --force
vendor/bin/typo3cms install:generatePackagestates --framework-extensions $TYPO3_ACTIVE_FRAMEWORK_EXTENSIONS --excluded-extensions $TYPO3_EXCLUDED_EXTENSIONS
vendor/bin/typo3cms install:fixfolderstructure
vendor/bin/typo3cms database:updateschema

