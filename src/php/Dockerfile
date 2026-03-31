# Headgent PHP-FPM – Multi-Stage Build
# All ARGs must be provided via --build-arg (no defaults = single source of truth in .env)

# Global ARGs for FROM statements (must be declared before any FROM)
ARG COMPOSER_VERSION
ARG ALPINE_VERSION
ARG PHP_VERSION

# --------------------
# Composer stage
# --------------------
FROM composer:${COMPOSER_VERSION} AS composer

# --------------------
# Build stage
# --------------------
FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION} AS build
LABEL maintainer="HeadgentOps <devops@headgent.dev>"

ARG APCU_VERSION
ARG REDIS_PECL_VERSION
ARG XDEBUG_VERSION
ARG PCOV_VERSION
ARG AMQP_VERSION
ARG RDKAFKA_VERSION

RUN apk add --no-cache \
      autoconf make g++ gcc libc-dev linux-headers libzip-dev libxml2-dev oniguruma-dev icu-dev curl-dev \
      libjpeg-turbo-dev libpng-dev freetype-dev pcre2-dev re2c pkgconf flex bison libxslt-dev python3 perl gperf \
      gawk sed grep findutils coreutils postgresql-dev \
      rabbitmq-c-dev librdkafka-dev \
 && export LC_ALL=C \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j"$(nproc)" curl soap zip mbstring intl bcmath gd sockets exif pdo_mysql mysqli pdo_pgsql \
 && docker-php-ext-install -j1 dom \
 && pecl channel-update pecl.php.net \
 && pecl config-set preferred_state stable \
 && yes "" | pecl install -o -f \
      apcu-${APCU_VERSION} \
      redis-${REDIS_PECL_VERSION} \
      amqp-${AMQP_VERSION} \
      rdkafka-${RDKAFKA_VERSION} \
      xdebug-${XDEBUG_VERSION} \
      pcov-${PCOV_VERSION} \
 && docker-php-ext-enable apcu redis amqp rdkafka xdebug pcov \
 && docker-php-ext-enable opcache || true

# --------------------
# Runtime stage
# --------------------
FROM php:${PHP_VERSION}-fpm-alpine${ALPINE_VERSION}
LABEL maintainer="HeadgentOps <devops@headgent.dev>"

# Re-declare build-time ARGs for runtime stage
ARG PUID
ARG PGID
ARG PHP_MEMORY_LIMIT
ARG PHP_MAX_EXECUTION_TIME
ARG PHP_TIMEZONE
ARG PHP_ERROR_REPORTING
ARG PHP_DISPLAY_ERRORS
ARG PHP_LOG_ERRORS
ARG APCU_SHM_SIZE
ARG OPCACHE_MEMORY_CONSUMPTION
ARG OPCACHE_MAX_ACCELERATED_FILES
ARG OPCACHE_VALIDATE_TIMESTAMPS
ARG OPCACHE_REVALIDATE_FREQ
ARG OPCACHE_JIT
ARG OPCACHE_JIT_BUFFER_SIZE
ARG XDEBUG_MODE
ARG XDEBUG_START_WITH_REQUEST
ARG XDEBUG_CLIENT_HOST
ARG XDEBUG_CLIENT_PORT
ARG XDEBUG_LOG_LEVEL
ARG XDEBUG_IDEKEY
ARG PCOV_ENABLED
ARG FPM_PM
ARG FPM_PM_MAX_CHILDREN
ARG FPM_PM_START_SERVERS
ARG FPM_PM_MIN_SPARE_SERVERS
ARG FPM_PM_MAX_SPARE_SERVERS
ARG FPM_PM_MAX_REQUESTS

# ENV defaults for runtime configuration (from .env via ARG, overrideable at runtime)
ENV APP_USER=appuser \
    PHP_MEMORY_LIMIT=${PHP_MEMORY_LIMIT} \
    PHP_MAX_EXECUTION_TIME=${PHP_MAX_EXECUTION_TIME} \
    PHP_TIMEZONE=${PHP_TIMEZONE} \
    PHP_ERROR_REPORTING=${PHP_ERROR_REPORTING} \
    PHP_DISPLAY_ERRORS=${PHP_DISPLAY_ERRORS} \
    PHP_LOG_ERRORS=${PHP_LOG_ERRORS} \
    APCU_SHM_SIZE=${APCU_SHM_SIZE} \
    OPCACHE_MEMORY_CONSUMPTION=${OPCACHE_MEMORY_CONSUMPTION} \
    OPCACHE_MAX_ACCELERATED_FILES=${OPCACHE_MAX_ACCELERATED_FILES} \
    OPCACHE_VALIDATE_TIMESTAMPS=${OPCACHE_VALIDATE_TIMESTAMPS} \
    OPCACHE_REVALIDATE_FREQ=${OPCACHE_REVALIDATE_FREQ} \
    OPCACHE_JIT=${OPCACHE_JIT} \
    OPCACHE_JIT_BUFFER_SIZE=${OPCACHE_JIT_BUFFER_SIZE} \
    XDEBUG_MODE=${XDEBUG_MODE} \
    XDEBUG_START_WITH_REQUEST=${XDEBUG_START_WITH_REQUEST} \
    XDEBUG_CLIENT_HOST=${XDEBUG_CLIENT_HOST} \
    XDEBUG_CLIENT_PORT=${XDEBUG_CLIENT_PORT} \
    XDEBUG_LOG_LEVEL=${XDEBUG_LOG_LEVEL} \
    XDEBUG_IDEKEY=${XDEBUG_IDEKEY} \
    PCOV_ENABLED=${PCOV_ENABLED} \
    FPM_PM=${FPM_PM} \
    FPM_PM_MAX_CHILDREN=${FPM_PM_MAX_CHILDREN} \
    FPM_PM_START_SERVERS=${FPM_PM_START_SERVERS} \
    FPM_PM_MIN_SPARE_SERVERS=${FPM_PM_MIN_SPARE_SERVERS} \
    FPM_PM_MAX_SPARE_SERVERS=${FPM_PM_MAX_SPARE_SERVERS} \
    FPM_PM_MAX_REQUESTS=${FPM_PM_MAX_REQUESTS}

# Runtime libs + security updates
# su-exec: lightweight privilege drop (like gosu)
# shadow: provides usermod/groupmod for UID/GID adjustment
RUN set -eux; \
    apk upgrade --no-cache && \
    apk add --no-cache bash git icu-libs libzip libxml2 oniguruma libjpeg-turbo libpng freetype postgresql-libs rabbitmq-c librdkafka fcgi su-exec shadow && \
    rm -rf /var/cache/apk/* /tmp/* && \
    cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini

# Composer
COPY --from=composer /usr/bin/composer /usr/local/bin/composer

# Copy built extensions & INIs from build stage
COPY --from=build /usr/local/lib/php/extensions/ /usr/local/lib/php/extensions/
COPY --from=build /usr/local/etc/php/conf.d/   /usr/local/etc/php/conf.d/

# Load OPcache INI early
RUN if [ -f /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini ]; then \
      mv /usr/local/etc/php/conf.d/docker-php-ext-opcache.ini /usr/local/etc/php/conf.d/00-opcache.ini; \
    fi

# Entrypoint
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Non-root user & runtime-config directories
RUN addgroup -g ${PGID} ${APP_USER} \
 && adduser -G ${APP_USER} -u ${PUID} -D -s /bin/bash ${APP_USER} \
 && mkdir -p /app /home/${APP_USER}/php-config /run/php-fpm \
 && chown -R ${APP_USER}:${APP_USER} /app /home/${APP_USER} /run/php-fpm \
 && : > /home/${APP_USER}/php-config/99-runtime-config.ini \
 && chown ${APP_USER}:${APP_USER} /home/${APP_USER}/php-config/99-runtime-config.ini \
 && ln -sf /home/${APP_USER}/php-config/99-runtime-config.ini /usr/local/etc/php/conf.d/99-runtime-config.ini \
 && : > /home/${APP_USER}/php-config/zz-fpm-runtime.conf \
 && chown ${APP_USER}:${APP_USER} /home/${APP_USER}/php-config/zz-fpm-runtime.conf \
 && ln -sf /home/${APP_USER}/php-config/zz-fpm-runtime.conf /usr/local/etc/php-fpm.d/zz-fpm-runtime.conf

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD sh -c "SCRIPT_NAME=/ping SCRIPT_FILENAME=/ping REQUEST_METHOD=GET cgi-fcgi -bind -connect 127.0.0.1:9000 | grep -q pong"

WORKDIR /app
EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
CMD ["php-fpm"]
