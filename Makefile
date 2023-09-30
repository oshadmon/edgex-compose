# Makefile for Docker Compose

# Define the name of your Docker Compose file
COMPOSE_FILE := docker-compose-with-app-sample.yml

# Define default target
default: help

help:
	@echo "Available targets:"
	@echo "  start            Start containers"
	@echo "  stop             Stop containers"
	@echo "  restart          Restart containers"
	@echo "  rebuild          Rebuild containers"
	@echo "  clean            Clean up containers and volumes"
	@echo "  logs             View container logs"
	@echo "  ps               List running containers"

start:
	docker-compose -f $(COMPOSE_FILE) up -d

stop:
	docker-compose -f $(COMPOSE_FILE) down

restart:
	docker-compose -f $(COMPOSE_FILE) restart

rebuild:
	docker-compose -f $(COMPOSE_FILE) up --build -d

clean: stop
	docker-compose -f $(COMPOSE_FILE) rm -f
	docker volume prune -f

logs:
	docker-compose -f $(COMPOSE_FILE) logs -f

ps:
	docker-compose -f $(COMPOSE_FILE) ps

.PHONY: help start stop restart rebuild clean logs ps
