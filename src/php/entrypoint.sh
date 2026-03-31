#!/bin/bash
set -e

# Headgent PHP-FPM Entrypoint - Runtime configuration from ENV variables

# UID/GID adjustment to match mounted volume owner (fixes macOS UID 501, GitHub Actions UID 1001)
if [ -d "/app" ] && [ "$(id -u)" = "0" ]; then
    HOST_UID=$(stat -c '%u' /app 2>/dev/null || echo "1000")
    HOST_GID=$(stat -c '%g' /app 2>/dev/null || echo "1000")
    [ "$HOST_GID" != "0" ] && [ "$HOST_GID" != "$(id -g $APP_USER)" ] && groupmod -g "$HOST_GID" "$APP_USER" 2>/dev/null || true
    [ "$HOST_UID" != "0" ] && [ "$HOST_UID" != "$(id -u $APP_USER)" ] && usermod -u "$HOST_UID" "$APP_USER" 2>/dev/null || true
    chown -R "$APP_USER:$APP_USER" "/home/$APP_USER" /run/php-fpm 2>/dev/null || true
fi

mkdir -p /home/${APP_USER}/php-config

# PCOV and Xdebug are mutually exclusive
[ "${PCOV_ENABLED}" = "1" ] && XDEBUG_MODE=off && echo "info: PCOV enabled - disabling Xdebug"

# Generate PHP runtime configuration
cat > /home/${APP_USER}/php-config/99-runtime-config.ini << EOF
; Headgent PHP-FPM Runtime Configuration (generated at startup)
memory_limit = ${PHP_MEMORY_LIMIT}
max_execution_time = ${PHP_MAX_EXECUTION_TIME}
date.timezone = ${PHP_TIMEZONE}
error_reporting = ${PHP_ERROR_REPORTING}
display_errors = ${PHP_DISPLAY_ERRORS}
log_errors = ${PHP_LOG_ERRORS}
expose_php = Off

; APCu
apc.enabled = 1
apc.shm_size = ${APCU_SHM_SIZE}
apc.enable_cli = 1
apc.serializer = php

; OPcache
opcache.enable = 1
opcache.enable_cli = 1
opcache.memory_consumption = ${OPCACHE_MEMORY_CONSUMPTION}
opcache.interned_strings_buffer = 8
opcache.max_accelerated_files = ${OPCACHE_MAX_ACCELERATED_FILES}
opcache.revalidate_freq = ${OPCACHE_REVALIDATE_FREQ}
opcache.fast_shutdown = 1
opcache.validate_timestamps = ${OPCACHE_VALIDATE_TIMESTAMPS}
opcache.jit = ${OPCACHE_JIT}
opcache.jit_buffer_size = ${OPCACHE_JIT_BUFFER_SIZE}

; Xdebug (set XDEBUG_MODE=off for production)
xdebug.mode = ${XDEBUG_MODE}
xdebug.start_with_request = ${XDEBUG_START_WITH_REQUEST}
xdebug.client_host = ${XDEBUG_CLIENT_HOST}
xdebug.client_port = ${XDEBUG_CLIENT_PORT}
xdebug.log_level = ${XDEBUG_LOG_LEVEL}
xdebug.idekey = ${XDEBUG_IDEKEY}

; PCOV (set PCOV_ENABLED=1 for faster coverage)
pcov.enabled = ${PCOV_ENABLED}
EOF

# Generate PHP-FPM pool configuration
cat > /home/${APP_USER}/php-config/zz-fpm-runtime.conf << EOF
; Headgent PHP-FPM Pool Configuration (generated at startup)
[www]
user = ${APP_USER}
group = ${APP_USER}
listen = 9000
listen.owner = ${APP_USER}
listen.group = ${APP_USER}
pm = ${FPM_PM}
pm.max_children = ${FPM_PM_MAX_CHILDREN}
pm.start_servers = ${FPM_PM_START_SERVERS}
pm.min_spare_servers = ${FPM_PM_MIN_SPARE_SERVERS}
pm.max_spare_servers = ${FPM_PM_MAX_SPARE_SERVERS}
pm.max_requests = ${FPM_PM_MAX_REQUESTS}
pm.status_path = /status
ping.path = /ping
ping.response = pong
access.log = /dev/stdout
slowlog = /dev/stderr
request_slowlog_timeout = 5s
clear_env = no
catch_workers_output = yes
decorate_workers_output = no
EOF

echo "info: Runtime configuration generated"

# Privilege drop and execute
[ "$(id -u)" = "0" ] && exec su-exec "$APP_USER" "$@"
exec "$@"
