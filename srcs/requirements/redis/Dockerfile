FROM alpine:3.20

RUN apk update && apk add --no-cache redis

RUN mkdir -p /data /etc/redis

COPY conf/redis.conf /etc/redis/redis.conf

EXPOSE 6379

CMD ["redis-server", "/etc/redis/redis.conf"]
