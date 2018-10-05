#!/usr/bin/env bash

set -o pipefail  # trace ERR through pipes
set -o errtrace  # trace ERR through 'time command' and other functions
set -o nounset   ## set -u : exit the script if you try to use an uninitialised variable
set -o errexit   ## set -e : exit the script if any statement returns a non-true return value
# set -x # Uncomment for debugging

cd /app

bzcat /tmp/import/*-orbit.structure.sql.bz2 | mysql --max_allowed_packet=256M -h $TYPO3__DB__Connections__Default__host -u $TYPO3__DB__Connections__Default__user -p$TYPO3__DB__Connections__Default__password || true;
bzcat /tmp/import/*-orbit.data.sql.bz2 | mysql --max_allowed_packet=256M -h $TYPO3__DB__Connections__Default__host -u $TYPO3__DB__Connections__Default__user -p$TYPO3__DB__Connections__Default__password || true;
vendor/bin/typo3cms database:updateschema || true;
rm -rf web/fileadmin/* web/uploads/* private/* || true;
tar -zxf web/*.orbit.files.tar.gz -C web || true;
