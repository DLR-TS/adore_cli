SHELL:=/bin/bash

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")

include tools/make_gadgets/make_gadgets.mk
include tools/apt_cacher_ng_docker/apt_cacher_ng_docker.mk

.EXPORT_ALL_VARIABLES:
SOURCE_DIRECTORY:=${ROOT_DIR}
ADORE_CLI_WORKING_DIRECTORY:=${ROOT_DIR}
SUBMODULES_PATH:=${ROOT_DIR}/tools
DOCKER_CONFIG?=${SUBMODULES_PATH}/apt_cacher_ng_docker

include tools/adore_cli/adore_cli.mk

PROJECT:=$(shell basename "${ROOT_DIR}")
TAG:=$(shell bash tools/make_gadgets/tools/branch_name.sh)

MAKE_GADGETS_DIR:=${ROOT_DIR}/tools/make_gadgets
MAKE_GADGETS_FILES := $(wildcard $(MAKE_GADGETS_DIR)/*)
ifeq ($(MAKE_GADGETS_FILES),)
    $(shell git submodule update --init)
endif

.PHONY: build
build: clean build_adore_cli setup ## Build and setup adore cli

.PHONY: build_adore_cli
build_adore_cli: stop_adore_cli start_apt_cacher_ng build_adore_cli_core  ## builds the adore cli (must be called on any changes to the auto_deploy cli context)
	@echo PROJECT:TAG: ${PROJECT}
	docker image tag ${PROJECT}:${TAG} ${ADORE_CLI_PROJECT}_x11_display:${ADORE_CLI_TAG}

.PHONY: setup
setup: start_apt_cacher_ng ## Setup ADORe CLI 
	echo todo

.PHONY: clean
clean: ## Clean ADORe  build artifacts 
	echo todo
