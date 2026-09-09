FROM alpine:3.21

RUN apk update && apk upgrade && \
    apk add --no-cache mariadb mariadb-client && \
    mkdir -p /run/mysqld /var/lib/mysql && \
    chown -R mysql:mysql /run/mysqld /var/lib/mysql && \
    chmod 777 /run/mysqld

COPY conf/mariadb-server.cnf /etc/my.cnf.d/mariadb-server.cnf
COPY setup.sh /setup.sh

RUN chmod +x /setup.sh

CMD ["sh", "/setup.sh"]

