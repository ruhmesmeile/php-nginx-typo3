#!/usr/bin/env bash

if [ -d /app/api ]; then
  cd /tmp
  curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash

  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh"  ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

  cd /app/api
  nvm install
  nvm use

  npm install
  npm run server
fi
