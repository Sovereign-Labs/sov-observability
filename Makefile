.PHONY: up down restart logs ps clean grafana prometheus loki tempo influxdb help

PROJECT_ROOT := $(shell git rev-parse --show-toplevel)
DOCKER_COMPOSE := docker compose

# Default target
.DEFAULT_GOAL := help

## Start all services
start:
	@echo "Starting services..."
	@$(DOCKER_COMPOSE) up -d --build --force-recreate

## Stop all services
stop:
	@echo "Shutting down services..."
	@$(DOCKER_COMPOSE) down

## Restart all services
restart: down up

## Show logs for all services
logs:
	@$(DOCKER_COMPOSE) logs -f

## Clean up volumes and networks
clean:
	@echo "Cleaning up volumes and networks..."
	@$(DOCKER_COMPOSE) down -v --remove-orphans
	rm -rf grafana-alloy/storage/*
	rm -rf grafana-tempo/data/*
	rm -rf influxdb-data/engine/*
	rm -rf influxdb-data/influx*


## Show this help message
help:
	@echo "Available targets:"
	@awk '/^##/ {c=$$0} /^[a-z_-]+:/ {gsub("##", "", c); printf "  %-15s %s\n", $$1, c}' $(MAKEFILE_LIST)
