DOCKER_ENV ?= local
DOCKER_ENV_CONFIG ?= config/$(DOCKER_ENV).env
GIT_BUNDLE_NAME ?= $(shell basename $$(git config --local remote.origin.url) .git)-$(shell git symbolic-ref --short HEAD 2>/dev/null | awk -F '/' '{print $$1}')
DOCKER_LABEL ?= $(shell basename $$(git config --local remote.origin.url) .git)-$(shell git rev-parse --short HEAD 2>/dev/null)
DOCKER_BUNDLE_NAME ?= $(GIT_BUNDLE_NAME)-$(DOCKER_ENV)
BRANCH ?= master
TARGET_HOST = $(shell docker run --rm busybox:1.30.0-glibc ip route get 8.8.8.8 | tr -s ' ' | cut -d' ' -f3| tr -s '\n' '\n')

export DOCKER_ENV
export GIT_BUNDLE_NAME
export DOCKER_LABEL
export DOCKER_BUNDLE_NAME
export TARGET_HOST

DOCKER_COMPOSE_FILE = docker-compose.yaml
DOCKER_COMPOSE_FILE_OVERRIDE = docker-compose.$(DOCKER_ENV).yaml
DOCKER_COMPOSE_CMD_BASE = docker-compose -f $(DOCKER_COMPOSE_FILE) -p $(DOCKER_BUNDLE_NAME)

ifneq ($(wildcard $(DOCKER_COMPOSE_FILE_OVERRIDE)), )
DOCKER_COMPOSE_CMD_BASE = docker-compose -f $(DOCKER_COMPOSE_FILE_OVERRIDE) -p $(DOCKER_BUNDLE_NAME)
endif

ifneq ($(wildcard $(DOCKER_ENV_CONFIG)), )
$(shell cp $(DOCKER_ENV_CONFIG) .env)
endif

build:
	$(DOCKER_COMPOSE_CMD_BASE) build
push:
	$(DOCKER_COMPOSE_CMD_BASE) push
pull:
	$(DOCKER_COMPOSE_CMD_BASE) pull
start:
	$(DOCKER_COMPOSE_CMD_BASE) up -d --remove-orphans
stop:
	$(DOCKER_COMPOSE_CMD_BASE) down --remove-orphans --volumes


git-checkout:
	git submodule update --remote --recursive --init
	git submodule foreach -q --recursive 'echo Submodule $$name; git checkout $$(git config -f $$toplevel/.gitmodules submodule.$$name.branch || echo ${BRANCH}); echo \\n'
git-pull:
	git pull --rebase
	git submodule foreach --recursive 'git pull --rebase origin'
