FROM debian:bullseye
RUN apt-get update && apt-get install -y \
    apache2 \
    php7.4 \
    php7.4-fpm \
    php7.4-mysql \
    php7.4-gd \
    libapache2-mod-php7.4 \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    curl
    
COPY tools/php_extensions.sh /usr/local/bin/php_extensions.sh
RUN chmod +x /usr/local/bin/php_extensions.sh
# Run the script to install PHP extensions
RUN /usr/local/bin/php_extensions.sh

# Download adminer directly to the root of the web directory
RUN curl -L https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -o /var/www/html/index.php

# Keep the /adminer directory for backward compatibility with your nginx config
RUN mkdir -p /var/www/html/adminer \
    && curl -L https://github.com/vrana/adminer/releases/download/v4.8.1/adminer-4.8.1.php -o /var/www/html/adminer/index.php

# Remove the default index.html to prevent it from taking precedence over index.php
RUN rm -f /var/www/html/index.html

# Alternatively, you could modify DirectoryIndex to prioritize PHP files
# RUN sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/apache2/mods-available/dir.conf

# Update Apache configuration
RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf

EXPOSE 80

# Start PHP-FPM & Apache server
CMD service php7.4-fpm start && apache2ctl -D FOREGROUND
