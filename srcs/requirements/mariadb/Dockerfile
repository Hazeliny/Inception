FROM debian:bullseye

RUN apt update -y

RUN apt-get install mariadb-server -y

COPY tools/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

RUN mkdir -p /var/run/mysqld \
	&& chown -R mysql:mysql /var/run/mysqld \
	&& chmod 777 /var/run/mysqld

EXPOSE 3306

COPY tools/mariadb.sh /mariadb.sh

RUN chmod +x /mariadb.sh

CMD ["/mariadb.sh"]
