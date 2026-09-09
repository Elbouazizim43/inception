FROM alpine:3.21

RUN apk update && apk upgrade && \
    apk add --no-cache nginx openssl && \
    mkdir -p /var/www/html /etc/ssl/certs /etc/ssl/private

COPY setup.sh /setup.sh
COPY nginx.conf /etc/nginx/nginx.conf

RUN chmod +x /setup.sh

CMD ["sh", "/setup.sh"]
