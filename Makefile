# /*******************************************************************************
#  * Copyright 2021 Intel
#  *
#  * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except
#  * in compliance with the License. You may obtain a copy of the License at
#  *
#  * http://www.apache.org/licenses/LICENSE-2.0
#  *
#  * Unless required by applicable law or agreed to in writing, software distributed under the License
#  * is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express
#  * or implied. See the License for the specific language governing permissions and limitations under
#  * the License.
#  *
#  *******************************************************************************/

.PHONY: help portainer portainer-down pull run pull-ui run-ui down-ui down clean get-token
.SILENT: help get-token

help:
	echo "See README.md in this folder"

ARGS:=$(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
$(eval $(ARGS):;@:)

OPTIONS:=" arm64 no-secty app-sample " # Must have spaces around words for `filter-out` function to work properly

# This tool now only supports compose V2, aka "docker compose" as it has replaced to old docker-compose tool.
DOCKER_COMPOSE=docker compose

ifeq (arm64, $(filter arm64,$(ARGS)))
	ARM64=-arm64
	ARM64_OPTION=arm64
endif
ifeq (no-secty, $(filter no-secty,$(ARGS)))
	NO_SECURITY:=-no-secty
endif
ifeq (app-sample, $(filter app-sample,$(ARGS)))
	APP_SAMPLE:=-with-app-sample
endif

SERVICES:=$(filter-out $(OPTIONS),$(ARGS))

define COMPOSE_DOWN
	${DOCKER_COMPOSE} -p edgex -f docker-compose.yml -f docker-compose-with-app-sample.yml down $1
endef

# Define additional phony targets for all options to enable support for tab-completion in shell
# Note: This must be defined after the options are parsed otherwise it will interfere with them
.PHONY: $(OPTIONS)

portainer:
	${DOCKER_COMPOSE} -p portainer -f docker-compose-portainer.yml up -d

portainer-down:
	${DOCKER_COMPOSE} -p portainer -f docker-compose-portainer.yml down

pull:
	${DOCKER_COMPOSE} -f docker-compose${NO_SECURITY}${ARM64}.yml pull ${SERVICES}

run:
	${DOCKER_COMPOSE} -p edgex -f docker-compose${NO_SECURITY}${APP_SAMPLE}${ARM64}.yml up -d ${SERVICES}

down:
	$(COMPOSE_DOWN)

clean:
	$(call COMPOSE_DOWN,-v)

get-token:
	DEV=$(DEV) \
	ARCH=$(ARCH) \
	cd ./compose-builder; sh get-api-gateway-token.sh

get-consul-acl-token:
	DEV=$(DEV) \
	ARCH=$(ARCH) \
	cd ./compose-builder; sh ./get-consul-acl-token.sh

# Docker Compose-related targets

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
