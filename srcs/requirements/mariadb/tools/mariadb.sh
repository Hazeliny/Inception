#!/bin/bash

#1 Check if env vars are available
if [ -z "$SQL_ROOT_PASSWORD" ] || [ -z "$SQL_DATABASE" ] || [ -z "$SQL_USER" ] || [ -z "$SQL_PASSWORD" ]; then
	echo "Error: there is one or more required environment variables missing"
	exit 1
fi

#2 Volume check
[ ! -d "$HOME/data/mysql" ] && mkdir -p "$Home/data/mysql"

#3 Mariadb service start and wait for it to be ready
service mariadb start

until mysqladmin ping --silent; do
	echo "Waiting until MariaDB is ready"
	sleep 1
done

#4 Try connection with no password, then with env stored password
mysql -u root -e "SELECT 1;" > /dev/null 2>&1
if [ $? -eq 0 ]; then
	echo "Connected to MariaDB without password, setting root password..."
  mysql -u root -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
else
  echo "Connecting to MariaDB with root password..."
  mysql -u root -p"${SQL_ROOT_PASSWORD}" -e "SELECT 1;" || { echo "MySQL connection failed"; exit 1; }
fi

#5 Execute SQL commands
mysql -u root -p"${SQL_ROOT_PASSWORD}" -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;" || { echo "Failed to create database"; exit 1; }
mysql -u root -p"${SQL_ROOT_PASSWORD}" -e "CREATE USER IF NOT EXISTS '${SQL_USER}'@'localhost' IDENTIFIED BY '${SQL_PASSWORD}';" || { echo "Failed to create user"; exit 1; }
mysql -u root -p"${SQL_ROOT_PASSWORD}" -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';" || { echo "Failed to grant privileges"; exit 1; }
mysql -u root -p"${SQL_ROOT_PASSWORD}" -e "FLUSH PRIVILEGES;" || { echo "Failed to flush privileges"; exit 1; }

mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" shutdown

exec mysqld_safe


