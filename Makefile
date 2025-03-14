
#DOCKER_COMPOSE := /usr/bin/docker compose

up:
	@echo "Starting containers"
	mkdir -p ${HOME}/data/wordpress
	mkdir -p ${HOME}/data/mysql
	sudo chmod -R 777 ${HOME}/data
	sudo chown -R $(USER) $(HOME)/data
	docker compose --env-file ./srcs/.env -f ./srcs/docker-compose.yml up -d --build

down:
	docker compose -f ./srcs/docker-compose.yml down --remove-orphans
	docker image prune -f

re:
	$(MAKE) down
	$(MAKE) up

clean:
	docker compose -f ./srcs/docker-compose.yml down --remove-orphans --rmi all --volumes
	docker volume prune

fresh:
	@echo "Cleaning up existing docker resources!"
	-docker stop $$(docker ps -qa); docker rm $$(docker ps -qa); \
	docker rmi -f $$(docker images -qa); docker volume rm $$(docker volume ls -q); \
	docker network rm $$(docker network ls -q)
	$(MAKE) up

fclean:
	$(MAKE) clean
	sudo rm -rf ${HOME}/data/mysql ${HOME}/data/wordpress

database:
	@docker exec -it mariadb -u linyao -p

database_root:
	@docker exec -it mariadb -u root -p
