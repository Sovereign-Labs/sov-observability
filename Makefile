.PHONY: up down restart logs ps clean grafana prometheus loki tempo influxdb help

PROJECT_ROOT := $(shell git rev-parse --show-toplevel)
DOCKER_COMPOSE := docker compose

# Default target
.DEFAULT_GOAL := help

## Start all services
start:
	@echo "Starting observability services..."
	@$(DOCKER_COMPOSE) up -d --build --force-recreate
	@echo "Waiting for all services to become healthy..."
	@timeout=60; \
	while [ $$timeout -gt 0 ]; do \
		if docker compose ps --format json | jq -e 'select(.Health != "healthy") | .Name' > /dev/null 2>&1; then \
			printf "\r⏳ Waiting for services... ($$timeout seconds remaining)    "; \
			sleep 1; \
			timeout=$$((timeout - 1)); \
		else \
			echo ""; \
			echo "✅ All observability services are healthy!"; \
			echo ""; \
			echo "🚀 Observability stack is ready:"; \
			echo "   - Grafana:     http://localhost:$${GRAFANA_PORT:-3000} (admin/admin123)"; \
			echo "   - InfluxDB:    http://localhost:$${INFLUX_PORT:-8086}"; \
			echo ""; \
			echo "📊 To monitor your rollup, check out https://sovlabs.notion.site/Tutorial-Getting-started-with-Grafana-Cloud-17e47ef6566b80839fe5c563f5869017?pvs=74"; \
			exit 0; \
		fi; \
	done; \
	echo ""; \
	echo "⚠️  Timeout waiting for services to become healthy"; \
	echo "Check service status with: docker compose ps"; \
	echo "View logs with: make logs"; \
	exit 1

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
