# Define the network
NETWORK_NAME = internal

# Default profile (you can change this)
PROFILE ?= all

# Docker Compose files
MAIN_COMPOSE_FILE = docker-compose.yml
MEDIA_SERVICES_COMPOSE_FILE = media-services/docker-compose.yml
SERVER_SERVICES_COMPOSE_FILE = server-services/docker-compose.yml
STRIIMU_SERVICES_COMPOSE_FILE = striimu-services/docker-compose.yml

# Define Docker Compose command
DOCKER_COMPOSE = docker compose

.PHONY: all network up down restart assets media server striimu logs local-stremio

all: up

up: network
	$(DOCKER_COMPOSE) -f $(MAIN_COMPOSE_FILE) --profile $(PROFILE) up -d
	$(DOCKER_COMPOSE) -f $(MEDIA_SERVICES_COMPOSE_FILE) --profile $(PROFILE) up -d
	$(DOCKER_COMPOSE) -f $(SERVER_SERVICES_COMPOSE_FILE) --profile $(PROFILE) up -d
	$(DOCKER_COMPOSE) -f $(STRIIMU_SERVICES_COMPOSE_FILE) --profile $(PROFILE) up -d

down:
	$(DOCKER_COMPOSE) -f $(STRIIMU_SERVICES_COMPOSE_FILE) --profile $(PROFILE) down
	$(DOCKER_COMPOSE) -f $(SERVER_SERVICES_COMPOSE_FILE) --profile $(PROFILE) down
	$(DOCKER_COMPOSE) -f $(MEDIA_SERVICES_COMPOSE_FILE) --profile $(PROFILE) down
	$(DOCKER_COMPOSE) -f $(MAIN_COMPOSE_FILE) --profile $(PROFILE) down

logs:
	$(DOCKER_COMPOSE) -f $(MAIN_COMPOSE_FILE) logs --follow &
	$(DOCKER_COMPOSE) -f $(MEDIA_SERVICES_COMPOSE_FILE) logs --follow &
	$(DOCKER_COMPOSE) -f $(SERVER_SERVICES_COMPOSE_FILE) logs --follow &
	$(DOCKER_COMPOSE) -f $(STRIIMU_SERVICES_COMPOSE_FILE) logs --follow &

# Restart the entire stack
restart: down up

# Bring up individual service groups
media:
	$(DOCKER_COMPOSE) -f $(MEDIA_SERVICES_COMPOSE_FILE) --profile $(PROFILE) up -d

local-stremio:
	$(DOCKER_COMPOSE) -f local-stremio/docker-compose.yml up -d
local-stremio-down:
	$(DOCKER_COMPOSE) -f local-stremio/docker-compose.yml down
local-stremio-logs:
	$(DOCKER_COMPOSE) -f local-stremio/docker-compose.yml logs --follow


server:
	$(DOCKER_COMPOSE) -f $(SERVER_SERVICES_COMPOSE_FILE) --profile $(PROFILE) up -d

striimu:
	$(DOCKER_COMPOSE) -f $(STRIIMU_SERVICES_COMPOSE_FILE) --profile $(PROFILE) up -d
