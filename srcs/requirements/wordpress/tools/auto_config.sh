#!/bin/bash

# Wait for the database service to be ready
until mysqladmin ping -h"$SQL_HOSTNAME" --silent; do
    sleep 2
done

if [ -f /var/www/wordpress/wp-config.php ]; then
    echo "WordPress already exists. Skipping installation."
else
    
    wp core download --allow-root

    # Generate wp-config.php
    wp config create \
        --dbname=$SQL_DATABASE \
        --dbuser=$SQL_USER \
        --dbpass=$SQL_PASSWORD \
        --dbhost=$SQL_HOSTNAME \
        --allow-root

    # Add Redis to wp-config.php
    wp config set WP_REDIS_HOST redis --allow-root
    wp config set WP_REDIS_PORT 6379 --allow-root
    wp config set WP_CACHE true --allow-root

    wp core install \
        --url=$DOMAIN_NAME \
        --title="$WORDPRESS_TITLE" \
        --admin_user=$WORDPRESS_ADMIN \
        --admin_password=$WORDPRESS_ADMIN_PASS \
        --admin_email=$WORDPRESS_ADMIN_EMAIL \
        --skip-email \
        --allow-root \

    wp user create $WORDPRESS_USER $WORDPRESS_EMAIL \
        --role=contributor \
        --user_pass=$WORDPRESS_USER_PASS \
        --allow-root \

    wp plugin install redis-cache --activate --allow-root
    wp redis enable --allow-root

    wp theme install twentytwentyfour --activate --allow-root

    FRONT_PAGE_ID=$(wp post list --post_type=page --post_status=publish --field=ID --title="Please kill me :)" --allow-root)

    wp option update page_on_front $FRONT_PAGE_ID --allow-root
    wp option update show_on_front 'page' --allow-root


    adduser $FTP_USER www-data
    chown -R www-data:www-data /var/www
    chmod -R g+rw /var/www
    
fi

# Start PHP-FPM in the foreground for proper container behavior
exec /usr/sbin/php-fpm7.4 -F
