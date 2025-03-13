FROM debian:bullseye

RUN apt-get -y update
RUN apt-get -y upgrade

RUN apt-get install -y php7.4 php-fpm php-mysql php-gd mariadb-client curl php-redis

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/

RUN mkdir -p /run/php && chmod 755 /run/php

RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp

COPY tools/auto_config.sh /usr/local/bin/auto_config.sh
RUN chmod +x /usr/local/bin/auto_config.sh

WORKDIR /var/www/html

RUN chown -R www-data:www-data /var/www/html
RUN mkdir -p /var/www/html/wp-content/uploads
RUN chmod -R 755 /var/www/html/

ENTRYPOINT ["bash", "/usr/local/bin/auto_config.sh"]
