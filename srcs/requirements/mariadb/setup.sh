#!/bin/sh

set -e

if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing fresh MariaDB database..."
    chown -R mysql:mysql /var/lib/mysql /run/mysqld
    mariadb-install-db --datadir=/var/lib/mysql --skip-test-db --user=mysql --group=mysql

    cat << EOF > /tmp/init.sql
FLUSH PRIVILEGES;
CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASS}';
GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASS}';
FLUSH PRIVILEGES;
EOF

    echo "Running MariaDB bootstrap..."
    mariadbd --user=mysql --bootstrap < /tmp/init.sql
    rm -f /tmp/init.sql
    echo "MariaDB database initialization complete."
fi

chown -R mysql:mysql /var/lib/mysql /run/mysqld

echo "Starting MariaDB..."
exec mariadbd --user=mysql --console
