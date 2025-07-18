.PHONY: up down wait-compose-ready restart logs postgres

PROJECT_ROOT := $(shell git rev-parse --show-toplevel)

up:
	@echo "Starting services"
	@docker_compose up -d --build --force-recreate
	@echo "Waiting for services to finish setup"
	@$(docker_compose) logs -f | awk '/Provisioning finished./ {print;exit}' # exit when encounter this log entry

down:
	@echo "Shutting down services"
	@$(docker_compose) down
	@echo "Removing generated configs"

restart: down up

logs:
	@$(docker_compose) logs -f
