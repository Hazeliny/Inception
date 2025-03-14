#!/bin/bash

# Install necessary PHP extensions
apt-get update && apt-get install -y \
    libpng-dev \
    libjpeg-dev \
    libfreetype6-dev \
    mariadb-client \
    curl \
    php7.4-gd \
    php7.4-mysqli \
    php7.4-pdo
