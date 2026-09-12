#!/bin/sh

set -e

echo "Generating self-signed SSL certificate for ${DOMAIN_NAME:-mohel-bo.42.fr}..."
mkdir -p /etc/ssl/certs /etc/ssl/private
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/origin.key \
    -out /etc/ssl/certs/origin.crt \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=Inception/CN=${DOMAIN_NAME:-mohel-bo.42.fr}"
chmod 600 /etc/ssl/private/origin.key
chmod 644 /etc/ssl/certs/origin.crt

sed -i "s/server_name .*/server_name ${DOMAIN_NAME:-mohel-bo.42.fr} www.${DOMAIN_NAME:-mohel-bo.42.fr};/g" /etc/nginx/nginx.conf

echo "Starting NGINX..."
exec nginx
