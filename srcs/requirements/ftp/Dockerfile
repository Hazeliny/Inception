FROM alpine:3.20

RUN apk add --no-cache pure-ftpd

COPY ./tools/ftp.sh /usr/local/bin/ftp.sh

RUN chmod 777 /usr/local/bin/ftp.sh

COPY ./conf/pure-ftpd.conf /etc/pure-ftpd.conf

EXPOSE 2121 21100-21110

CMD ["/usr/local/bin/ftp.sh"]
