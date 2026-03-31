ARG WEBSERVER_VERSION

FROM nginx:${WEBSERVER_VERSION}-alpine

ARG PUID
ARG PGID

# Nur gettext für envsubst und User/Group-Management
RUN apk add --no-cache gettext && \
    # Bestehende www-data Gruppe löschen falls vorhanden
    delgroup www-data 2>/dev/null || true && \
    deluser www-data 2>/dev/null || true && \
    # Neue Gruppe und User mit gewünschter ID erstellen
    addgroup -g ${PGID} -S appuser && \
    adduser -u ${PUID} -D -S appuser -G appuser && \
    # Nginx-Konfiguration anpassen
    sed -i '/^user /d' /etc/nginx/nginx.conf && \
    # Berechtigungen setzen
    chown -R appuser:appuser /var/cache/nginx /var/log/nginx /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown appuser:appuser /var/run/nginx.pid

# Template kopieren
COPY ./conf.d/default.conf.template /etc/nginx/conf.d/default.conf.template

# Entrypoint Script
COPY ./entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

USER appuser

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
