#!/bin/sh

set -e

if echo "$WP_ADMIN_USER" | grep -qi "admin"; then
    echo "FATAL: WP_ADMIN_USER ('$WP_ADMIN_USER') cannot contain 'admin' or 'Admin' (Subject requirement)."
    exit 1
fi

sed -i 's/listen = 127.0.0.1:9000/listen = 9000/1' /etc/php83/php-fpm.d/www.conf

echo "Waiting for MariaDB connection..."
retries=30
until mariadb-admin ping -h"mariadb" -u"$DB_USER" -p"$DB_PASS" --silent || [ $retries -eq 0 ]; do
    retries=$((retries - 1))
    sleep 2
done

if [ $retries -eq 0 ]; then
    echo "FATAL: MariaDB connection timed out."
    exit 1
fi
echo "MariaDB is ready."

if ! wp core is-installed --allow-root 2>/dev/null; then
    echo "WordPress is not installed. Running initial setup..."

    if [ ! -f "wp-config.php" ]; then
        wp core download --allow-root --force
        wp config create \
            --dbname="$DB_NAME" \
            --dbuser="$DB_USER" \
            --dbpass="$DB_PASS" \
            --dbhost="mariadb" \
            --allow-root
    fi

    wp core install --url="https://${DOMAIN_NAME}" \
                    --title="$WP_TITLE" \
                    --admin_user="$WP_ADMIN_USER" \
                    --admin_password="$WP_ADMIN_PASS" \
                    --admin_email="$WP_ADMIN_EMAIL" \
                    --skip-email \
                    --allow-root

    wp config set WP_HOME "https://${DOMAIN_NAME}" --allow-root
    wp config set WP_SITEURL "https://${DOMAIN_NAME}" --allow-root

    if ! wp user get "$WP_USER" --allow-root >/dev/null 2>&1; then
        wp user create "$WP_USER" "$WP_EMAIL" --role=author --user_pass="$WP_PASS" --allow-root
    fi
else
    echo "WordPress is already installed. Skipping initialization."
fi

chown -R nobody:nobody /var/www/html/wordpress
chmod -R 755 /var/www/html/wordpress

echo "Starting PHP-FPM..."
exec php-fpm83 -F
