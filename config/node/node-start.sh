#!/usr/bin/env bash

if [ -d /app/api ]; then
  cd /app/api
  /usr/bin/npm run server
fi
