#!/bin/sh
set -eu

# Runtime defaults
HOST="${HOST:-localhost}"
export HOST

echo "🔧 Processing nginx configuration template..."

# Template → finale Konfiguration
envsubst '$APP_ROOT $DOCUMENT_ROOT $INDEX_FILE $HOST $PHP_PORT' \
    < /etc/nginx/conf.d/default.conf.template \
    > /etc/nginx/conf.d/default.conf

echo "✅ Nginx configuration processed"
echo "🌐 Starting nginx..."

exec nginx -g 'daemon off;'
