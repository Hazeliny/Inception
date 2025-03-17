# Inception


https://github.com/mharriso/school21-checklists/blob/master/ng_3_inception.pdf

simple setup
open https://linyao.42.fr access the wordpress website
http://linyao.42.fr will be redirected to port 443 https
or
command:curl -v http://linyao.42.fr  
display:connect to 127.0.0.1 port 80 failed: Connection refused
command:curl -v https://linyao.42.fr
display:Connected to linyao.42.fr (127.0.0.1) port 443 (#0)  and  TLSv1.3 list



docker network
command: docker network ls
explain docker-network

nginx with SSL/TLS
command: docker-compose ps (must run the command in the folder srcs/)
try to access nginx service via http: curl -I http://localhost (cannot connect)
(optional: before this command, you can use "docker ps" to get the container id, then use "docker exec -it <CONTAINER_ID> nginx -t",  successful message)



Wordpress with php-fpm and its volume
command: docker volume ls
docker volume inspect srcs_wordpress_data
(this is a named volume managed in the docker internally instead of bind mount controlled by host)








1. docker stop $(docker ps -qa)

docker ps -qa：列出所有容器（包括运行中的和已停止的），只显示容器 ID。
docker stop $(...)：停止所有容器。
作用：停止所有容器。

2. docker rm $(docker ps -qa)

docker ps -qa：同上，列出所有容器 ID。
docker rm $(...)：删除所有容器。
作用：删除所有容器。

3. docker rmi -f $(docker image -qa)

docker image -qa：列出所有镜像的 ID。
docker rmi -f $(...)：强制删除所有镜像。
作用：删除所有 Docker 镜像。

4. docker volume rm $(docker volume ls -q)

docker volume ls -q：列出所有 Docker 卷的 ID。
docker volume rm $(...)：删除所有 Docker 卷。
作用：删除所有 Docker 数据卷（持久化存储）。

5. docker network rm $(docker network ls -q) >2/dev/null

docker network ls -q：列出所有 Docker 网络的 ID。
docker network rm $(...)：删除所有 Docker 网络（默认网络可能无法删除）。
>2/dev/null：将错误输出重定向到 /dev/null，避免显示错误信息（例如尝试删除默认网络时报错）。
作用：删除所有 Docker 网络，忽略报错信息。

What is WP-CLI?
WP-CLI is the command line interface for WordPress. It is a tool that allows you to interact with your WordPress site from the command line, it is used for a lot of purposes, such as automating tasks, debugging problems, installing/removing plugins along side with themes, managing users and roles, exporting/importing data, run databses queries, and so much more…













sudo adduser lin sudo - add user lin into the group sudo in virtual machine, after it reboot is needed
sudo usermod -aG sudo lin - add user lin into the group sudo in virtual machine, after it reboot is needed
reboot
sudo whoami - verify if lin is able to run commands with sudo privileges
sudo apt update - update everything after rebooting the VM
sudo getnet group sudo - check the group information with the name 'sudo'
groups lin - check if lin is now in the sudo group, the expected output: lin : lin sudo
sudo apt install appname - install app in virtual machine


SSH（Secure Shell）是一种加密网络协议，用于在不安全的网络上安全地访问远程服务器。它提供了安全的远程登录、命令执行和文件传输功能。相比传统的 Telnet，SSH 具有更高的安全性，因为它采用了加密技术（如 RSA、ECDSA）来防止数据被窃听或篡改。


Makefile

Part 1:up - 启动容器 (创建所需目录，调整权限，并启动 Docker Compose 服务)

mkdir -p ${HOME}/data/wordpress & mkdir -p ${HOME}/data/mysql
在 HOME 目录下创建 data/wordpress 和 data/mysql 目录（如果不存在）。

sudo chmod -R 777 ${HOME}/data
赋予 data 目录 完全权限（读、写、执行），确保 Docker 能访问这些文件。

sudo chown -R $(USER) $(HOME)/data
将 data 目录的所有者设置为当前用户，防止权限问题。

docker compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml up -d --build
--env-file ./srcs/.env：加载环境变量文件 .env，用于配置数据库密码等敏感信息。
-f ./srcs/docker-compose.yml：使用 docker-compose.yml 文件定义服务。

up -d --build：
-d：后台运行容器（detach mode）。
--build：强制重新构建容器。

Part 2:down - 停止并删除容器 (停止容器，清理未使用的镜像)

docker compose down --remove-orphans：停止并删除所有 Docker 容器，同时清理孤立（未被 docker-compose.yml 关联）的容器。
docker image prune -f：删除所有未使用的 Docker 镜像。

Part 3:re - 重新启动(“重启”所有 Docker 容器)

先执行 down（停止并删除容器），再执行 up（重启容器）。

Part 4:clean - 深度清理 (彻底清理与 docker-compose 相关的容器、镜像、数据卷)

docker compose down --remove-orphans --rmi all --volumes：
--rmi all：删除所有与该 docker-compose.yml 相关的 Docker 镜像。
--volumes：删除所有 Docker 数据卷（存储数据库等数据的地方）。
docker volume prune：删除所有未使用的 Docker 卷。

Part 5:fresh - 彻底清理后重新启动(清理整个 Docker 运行环境（所有容器、镜像、数据卷、网络）并重新启动)

彻底删除所有 Docker 相关资源

docker stop $(docker ps -qa)：停止所有容器。
docker rm $(docker ps -qa)：删除所有容器。
docker rmi -f $(docker images -qa)：删除所有镜像。
docker volume rm $(docker volume ls -q)：删除所有数据卷。
docker network rm $(docker network ls -q)：删除所有 Docker 网络。
重新启动

$(MAKE) up：执行 up 目标，重建容器。

Part 6:fclean - 彻底清理并删除数据(删除所有 Docker 相关内容，并清理本地存储的数据（数据库、WordPress 站点文件等）)

$(MAKE) clean：执行 clean 目标，删除所有容器、镜像、数据卷。
sudo rm -rf ${HOME}/data/mysql ${HOME}/data/wordpress：彻底删除 data 目录中的 MySQL 和 WordPress 数据。

Part 7:database - 进入数据库(进入 MariaDB 数据库，使用 lin 账户)

docker exec -it mariadb mariadb -u lin -p：
docker exec -it：进入正在运行的 mariadb 容器。
mariadb -u lin -p：使用 lin 用户连接 MariaDB，并要求输入密码。

Part 8:database_root - 以 root 用户访问数据库(进入 MariaDB 数据库，使用 root 账户)

和 database 目标类似，但使用 root 用户登录。
