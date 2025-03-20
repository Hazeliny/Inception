# Inception


## simple setup

Add user lin into the group sudo in virtual machine, after it reboot is needed
```
sudo adduser lin sudo
```

Add user lin into the group sudo in virtual machine, after it reboot is needed
```
sudo usermod -aG sudo lin
```

```
reboot
```

Verify if lin is able to run commands with sudo privileges
```
sudo whoami
```

Update everything after rebooting the VM

```
sudo apt update
```

Check the group information with the name 'sudo'

```
sudo getnet group sudo
```

Check if lin is now in the sudo group, the expected output: lin : lin sudo

```
groups lin
```

Install app in virtual machine

```
sudo apt install appname
```

If the mariadb initial table was empty, check if the enviroment variables are missing:
```
env | grep SQL_
```

If they were missing, it means that the macros with prefix $ failed to be loaded to shell, you must fixed it as below:
```
export $(grep -v '^#' .env | xargs)
```

Install Pure-FTPd

```
sudo apt update && sudo apt install -y pure-ftpd
```

Install portainer in the same manner above.


## Check

### General Infrastructure Check

Check all the dockers' status
```
Option 1: docker ps

Option 2: (Must in the directory srcs/) docker-compose ps

```

### Volume Verification

Check if the WordPress database and files are stored persistently in your volumes. My volume isn't defined as a bind mount that is in host machine and managed by host machine but as a named volume that is located in containers and controlled by containers, so it doesn't display the path: /home/linyao/data but a Mountpoint as this: "Mountpoint": "/var/lib/docker/volumes/srcs_mariadb_data/_data"

```
docker volume ls

docker inspect srcs_mariadb_data
```

Check Wordpress with php-fpm and its volume
```
Command: docker volume ls

Command: docker volume inspect srcs_wordpress_data
(This is a named volume managed in the docker internally instead of bind mount controlled by host)
```

### Database (MariaDB) Check

Enter mariadb database container firstly:

```
Command: docker exec -it mariadb mariadb -ulinyao -plin123 (or run 'make database')
```

```
SHOW DATABASES;
USE wordpress;
SHOW TABLES;
SELECT * FROM wp_users;
```

### WordPress Functionality Check

```
1. Visit in the browser: https://linyao.42.fr, it shouldn't display the installation page of WordPress but the user's mainpage(with user id linyao).

2. Write a comment in this page

3. Then visit: https://linyao.42.fr/wp-admin to show the login page of WordPress, then log in with administrator id(linyaoWP and its password as written in .env) or userid(linyao and its password as written in .env)

4. You can find the new comment written by the user

5. The administrator can also modify the page title in settings or add another new page, then log out.

6. Log in with user id, then you can find the page's title or the new page has been there.
```


### TLS (SSL) Verification for NGINX

```
Command: curl -I http://localhost

Display: Nginx can not be accessed via port 80

(Optional: before this command, you can use "docker ps" to get the container id, then use "docker exec -it <CONTAINER_ID> nginx -t",  successful message)
```

You can also check in the browser:
```
1. Go to https://your_login.42.fr

2. Click the lock icon → Certificate Info
```

```
Open https://linyao.42.fr access the wordpress website, http://linyao.42.fr will be redirected to port 443 https

or

Command:curl -v http://linyao.42.fr

Display:connect to 127.0.0.1 port 80 failed: Connection refused

Command:curl -v https://linyao.42.fr

Display:Connected to linyao.42.fr (127.0.0.1) port 443 (#0)  and  TLSv1.3 list
```

### Network Verification

```
Command: docker network ls
```

### Forbidden Practices Check

✅ Make sure:

No while true, tail -f, sleep infinity in entrypoints.

No host networking (network_mode: host should NOT exist).

No links or --link used in docker-compose.yml.

```
docker inspect <container_name>
```

### Domain Name Verification (login.42.fr)

Check for: The domain resolves to the local IP (127.0.0.1)

```
ping linyao.42.fr
```

If not, add it manually:

```
sudo nano /etc/hosts
```

Add this line:

```
127.0.0.1 linyao.42.fr
```

Save and exit (CTRL+X, Y, Enter).


## Usage

### Pure-FTPd

```
ftp localhost -p 2121
```

Iput username and password

Download the file from WordPress server to host and is placed in the root of inception porject
```
get wp-cron.php
```

Upload the file to WordPress server
```
put filename
```

### Adminer

Visit:

```
http://localhost:8082
```

input:

```
system: MySQL

Server: mariadb

username: linyao

password: lin123
```

### Redis

```
docker exec -it redis redis-cli

ping - display: pong

set mykey "Hello Redis!" - display: OK

get mykey - display: Hello Redis!
```

### portainer

```
https://localhost:9443
```

If it says timeout, to restart the container:

```
make re

or

docker restart portainer
```

Then create the new user and password to log in.


### go-web

```
https://localhost/go/

or

http://localhost:8080
```


## Common Commands for docker

1. docker stop $(docker ps -qa)

```
docker ps -qa：列出所有容器（包括运行中的和已停止的），只显示容器 ID。

docker stop $(...)：停止所有容器。
```

作用：停止所有容器。

2. docker rm $(docker ps -qa)

```
docker ps -qa：同上，列出所有容器 ID。

docker rm $(...)：删除所有容器。
```

作用：删除所有容器。

3. docker rmi -f $(docker image -qa)

```
docker image -qa：列出所有镜像的 ID。

docker rmi -f $(...)：强制删除所有镜像。
```

作用：删除所有 Docker 镜像。

4. docker volume rm $(docker volume ls -q)

```
docker volume ls -q：列出所有 Docker 卷的 ID。

docker volume rm $(...)：删除所有 Docker 卷。
```

作用：删除所有 Docker 数据卷（持久化存储）。

5. docker network rm $(docker network ls -q) >2/dev/null

```
docker network ls -q：列出所有 Docker 网络的 ID。

docker network rm $(...)：删除所有 Docker 网络（默认网络可能无法删除）。

\>2/dev/null：将错误输出重定向到 /dev/null，避免显示错误信息（例如尝试删除默认网络时报错）。
```

作用：删除所有 Docker 网络，忽略报错信息。

## Some Concepts

### What is Docker?

Docker is a tool designed to allow you to build, deploy and run applications in an isolated and consistent manner across different machines and operating systems. This process is done using CONTAINERS. which are lightweight virtualized environments that package all the dependencies and code an application needs to run into a single text file, which can run the same way on any machine.

While Docker is primarily used to package and run applications in containers, it is not limited to that use case. Docker can also be used to create and run other types of containers, such as ones for testing, development, or experimentation.

### What is a Docker Image?

Docker Image is a lightweight executable package that includes everything the application needs to run, including the code, runtime environment, system tools, libraries, and dependencies.

Although it cannot guarantee error-free performance, as the behavior of an application ultimately depends on many factors beyond the image itself, using Docker can reduce the likelihood of unexpected errors.

Docker Image is built from a DOCKERFILE, which is a simple text file that contains a set of instructions for building the image, with each instruction creating a new layer in the image.

### What is a Dockerfile?

Dockerfile is that SIMPLE TEXT FILE that I mentioned earlier, which contains a set of instructions for building a Docker Image. It specifies the base image to use and then includes a series of commands that automate the process for configuring and building the image, such as installing packages, copying files, and setting environment variables. Each command in the Dockerfile creates a new layer in the image.

### What is a Docker Compose?

Docker Compose is a powerful tool that simplifies the deployment and management of multi-container Docker applications. It provides several benefits, including simplifying the process of defining related services, volumes for data persistence, and networks for connecting containers. With Docker Compose, you can easily configure each service’s settings, including the image to use, the ports to expose, and the environment variables to set…

A Docker Compose has 3 important parts, which are: Services, Networks, Volumes.

### What is a Container?

A Container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another.

### What is PID 1?

In a Docker container, the PID 1 process is a special process that plays an important role in the container’s lifecycle. This process is the identifier of the init process, which is the first process that is started when the system boots up, and it is responsible for starting and stoping all of the other processes on the system. And in Docker as well, the init process is responsible for starting and stoping the application that is running in the container.

### Is the Daemon Process PID 1? And How Does They Differ From Each Other?

The daemon process is NOT the PID 1, the daemon process is a background process that runs continuosuly on a system and performs a specific task. In contrast, PID 1 is the first process that the kernel starts in a Unix-based system and plays a special role in the system.

### What is WP-CLI?
WP-CLI is the command line interface for WordPress. It is a tool that allows you to interact with your WordPress site from the command line, it is used for a lot of purposes, such as automating tasks, debugging problems, installing/removing plugins along side with themes, managing users and roles, exporting/importing data, run databses queries, and so much more…

### SSH

SSH（Secure Shell）是一种加密网络协议，用于在不安全的网络上安全地访问远程服务器。它提供了安全的远程登录、命令执行和文件传输功能。相比传统的 Telnet，SSH 具有更高的安全性，因为它采用了加密技术（如 RSA、ECDSA）来防止数据被窃听或篡改。

### What is FTP? And How Does it Work?

FTP or File Transfer Protocol is a protocol that’s used for transferring files between a client and a server over TCP/IP network, such as the internet. It provides a robust mechanism for users to upload, download, and manage files on remote servers.

FTP works by opening two connections that link the 2 hosts (client and server) trying to communicate between each other, one connection is designed for the commands and replies that gets sent between the two clients, and the other connection is handles the transfer of the data.

### What is Adminer?

Adminer is a free open-source tool that allows you to easily view, edit, create, and modify databases through a user-friendly interface. It supports a wide range of database systems, such as MariaDB, MySQL, PostgreSQL, SQLite, and many more… It is a single file application that doesn’t require any installation, and that is what makes Adminer stand out and be preferred as a database manager among all the other alternatives.

### What is Redis Cache?

Redis is an in-memory data structure store that can be used as a database, cache, and message broker. It supports a variety of data structures such as strings, hashes, lists, sets, and more. One of the main features of Redis is its ability to cache data in memory, which allows it to achieve very fast read and write speeds. Redis can be used to improve the performance of web applications by reducing the time it takes to access data from a database or other slow storage layer. In addition to its caching capabilities, Redis also offers publish/subscribe messaging, transactions, and support for multiple data structures, making it a versatile tool for a variety of use cases.

### What is portainer?

Portainer is a lightweight, web-based UI for managing Docker containers, images, volumes, networks, and even Kubernetes clusters.

Why Use Portainer?

✅ Easy Docker Management – No need to memorize CLI commands.

✅ Web Dashboard – Access your containers, logs, and stats from a browser.

✅ Deploy & Monitor – Start, stop, or restart containers with a few clicks.

✅ Volume & Network Control – Manage persistent storage and container networking.

### What is go-web?

Go-Web usually refers to a web application or API built using Go (Golang). It could be a custom-built web service running inside your Docker environment to handle specific tasks, such as:

A backend API for handling requests

A web application serving dynamic content

A microservice within a larger system

### Makefile

#### Part 1:up - 启动容器 (创建所需目录，调整权限，并启动 Docker Compose 服务)

```
mkdir -p ${HOME}/data/wordpress & mkdir -p ${HOME}/data/mysql
```

在 HOME 目录下创建 data/wordpress 和 data/mysql 目录（如果不存在）。

```
sudo chmod -R 777 ${HOME}/data
```

赋予 data 目录 完全权限（读、写、执行），确保 Docker 能访问这些文件。

```
sudo chown -R $(USER) $(HOME)/data
```
将 data 目录的所有者设置为当前用户，防止权限问题。

```
docker compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml up -d --build
```

--env-file ./srcs/.env：加载环境变量文件 .env，用于配置数据库密码等敏感信息。

-f ./srcs/docker-compose.yml：使用 docker-compose.yml 文件定义服务。

```
up -d --build：
```

-d：后台运行容器（detach mode）。

--build：强制重新构建容器。

#### Part 2:down - 停止并删除容器 (停止容器，清理未使用的镜像)

```
docker compose down --remove-orphans：停止并删除所有 Docker 容器，同时清理孤立（未被 docker-compose.yml 关联）的容器。

docker image prune -f：删除所有未使用的 Docker 镜像。
```

#### Part 3:re - 重新启动(“重启”所有 Docker 容器)

先执行 down（停止并删除容器），再执行 up（重启容器）。

#### Part 4:clean - 深度清理 (彻底清理与 docker-compose 相关的容器、镜像、数据卷)

```
docker compose down --remove-orphans --rmi all --volumes
```

--rmi all：删除所有与该 docker-compose.yml 相关的 Docker 镜像。

--volumes：删除所有 Docker 数据卷（存储数据库等数据的地方）。

```
docker volume prune：删除所有未使用的 Docker 卷。
```

#### Part 5:fresh - 彻底清理后重新启动(清理整个 Docker 运行环境（所有容器、镜像、数据卷、网络）并重新启动)

彻底删除所有 Docker 相关资源

```
docker stop $(docker ps -qa)：停止所有容器。

docker rm $(docker ps -qa)：删除所有容器。

docker rmi -f $(docker images -qa)：删除所有镜像。

docker volume rm $(docker volume ls -q)：删除所有数据卷。

docker network rm $(docker network ls -q)：删除所有 Docker 网络。
```

重新启动

```
$(MAKE) up：执行 up 目标，重建容器。
```

#### Part 6:fclean - 彻底清理并删除数据(删除所有 Docker 相关内容，并清理本地存储的数据（数据库、WordPress 站点文件等）)

```
$(MAKE) clean：执行 clean 目标，删除所有容器、镜像、数据卷。

sudo rm -rf ${HOME}/data/mysql ${HOME}/data/wordpress：彻底删除 data 目录中的 MySQL 和 WordPress 数据。
```

#### Part 7:database - 进入数据库(进入 MariaDB 数据库，使用 lin 账户)

```
docker exec -it mariadb mariadb -u lin -p：
docker exec -it：进入正在运行的 mariadb 容器。
mariadb -u lin -p：使用 lin 用户连接 MariaDB，并要求输入密码。
```

#### Part 8:database_root - 以 root 用户访问数据库(进入 MariaDB 数据库，使用 root 账户)

和 database 目标类似，但使用 root 用户登录。
