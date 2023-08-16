
# This Makefile contains useful targets that can be included in downstream projects.

ifeq ($(filter adore_cli.mk, $(notdir $(MAKEFILE_LIST))), adore_cli.mk)

.EXPORT_ALL_VARIABLES:
SHELL:=/bin/bash
ADORE_CLI_PROJECT:=adore-cli

ADORE_CLI_MAKEFILE_PATH:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")
ifeq ($(SUBMODULES_PATH),)
    ADORE_CLI_SUBMODULES_PATH:=${ADORE_CLI_MAKEFILE_PATH}
else
    ADORE_CLI_SUBMODULES_PATH:=$(shell realpath ${SUBMODULES_PATH})
endif
MAKE_GADGETS_PATH:=${ADORE_CLI_SUBMODULES_PATH}/make_gadgets
ifeq ($(wildcard $(MAKE_GADGETS_PATH)/*),)
    $(info INFO: To clone submodules use: 'git submodules update --init --recursive')
    $(info INFO: To specify alternative path for submodules use: SUBMODULES_PATH="<path to submodules>" make build')
    $(info INFO: Default submodule path is: ${ADORE_CLI_MAKEFILE_PATH}')
    $(error "ERROR: ${MAKE_GADGETS_PATH} does not exist. Did you clone the submodules?")
endif

ADORE_CLI_TAG:=$(shell cd "${MAKE_GADGETS_PATH}" && make get_sanitized_branch_name REPO_DIRECTORY="${ADORE_CLI_MAKEFILE_PATH}")
ADORE_CLI_IMAGE:=${ADORE_CLI_PROJECT}:${ADORE_CLI_TAG}
ADORE_CLI_PROJECT_X11_DISPLAY:=${ADORE_CLI_PROJECT}_x11-display
ADORE_CLI_IMAGE_X11_DISPLAY:=${ADORE_CLI_PROJECT_X11_DISPLAY}:${ADORE_CLI_TAG}

SOURCE_DIRECTORY?=${REPO_DIRECTORY}

DOCKER_COMPOSE_FILE?=${ADORE_CLI_MAKEFILE_PATH}/docker-compose.yaml

##ADORE_PATH:=$(shell (find "${ADORE_CLI_SUBMODULES_PATH}" -name adore.mk | xargs realpath | sed "s|/adore.mk||g") 2>/dev/null || true )
#ADORE_CLI_WORKING_DIRECTORY?=${ADORE_CLI_MAKEFILE_PATH}

UID := $(shell id -u)
GID := $(shell id -g)


TEST_SCENARIOS?=adore_scenarios/baseline_test.launch


include ${MAKE_GADGETS_PATH}/make_gadgets.mk
include ${MAKE_GADGETS_PATH}/docker/docker-tools.mk
include ${ADORE_CLI_SUBMODULES_PATH}/adore_if_ros/adore_if_ros.mk
include ${ADORE_CLI_SUBMODULES_PATH}/plotlabserver/plotlabserver.mk
include ${ADORE_CLI_SUBMODULES_PATH}/catkin_docker/catkin_docker.mk
include ${ADORE_CLI_SUBMODULES_PATH}/catkin_docker/catkin_base.mk
include ${ADORE_CLI_SUBMODULES_PATH}/apt_cacher_ng_docker/apt_cacher_ng_docker.mk

REPO_DIRECTORY:=${ADORE_CLI_MAKEFILE_PATH}
#CATKIN_WORKSPACE_DIRECTORY:=${REPO_DIRECTORY}/catkin_workspace

ADORE_CLI_SUBMODULES:=make_gadgets adore_if_ros plotlabserver catkin_docker apt_cacher_ng_docker 
#include ${MAKE_GADGETS_PATH}/submodule_utils.mk
#$(call include_submodules,${ADORE_CLI_SUBMODULES_PATH}, ${ADORE_CLI_SUBMODULES})

.PHONY: adore_if_ros_check
adore_if_ros_check:
	@if [ -z "$$(docker images -q '${ADORE_IF_ROS_PROJECT}:${ADORE_IF_ROS_TAG}')" ]; then \
        echo "adore_if_ros docker image: ${ADORE_IF_ROS_PROJECT}:${ADORE_IF_ROS_TAG} does not exits in the local docker repository. "; \
        echo "Did you build adore_if_ros?"; \
        echo "  Hint: run 'make build' to build adore_if_ros."; \
        exit 1; \
    fi

.PHONY: adore-cli_up
adore-cli_up: adore-cli_setup adore-cli_start adore-cli_attach adore-cli_teardown 

.PHONY: adore-cli_up_
adore-cli_up_: adore-cli_setup adore-cli_start 

.PHONY: cli
cli: adore-cli ## Same as 'make adore-cli' for the lazy 

.PHONY: stop_adore-cli
stop_adore-cli: docker_host_context_check adore-cli_teardown ## Stop adore-cli docker context if it is running

.PHONY: adore-cli 
adore-cli: docker_host_context_check start_apt_cacher_ng build_fast_adore_if_ros build_fast_adore-cli ## Start adore-cli context or attach to it if already running
	@if [[ "$$(docker inspect -f '{{.State.Running}}' '${ADORE_CLI_PROJECT}' 2>/dev/null)" == "true"  ]]; then\
        cd "${ADORE_CLI_MAKEFILE_PATH}" && make --file=${ADORE_CLI_MAKEFILE_PATH}/adore_cli.mk adore-cli_attach;\
        exit 0;\
    else\
        cd "${ADORE_CLI_MAKEFILE_PATH}" && make --file=${ADORE_CLI_MAKEFILE_PATH}/adore_cli.mk adore-cli_up;\
        exit 0;\
    fi;

.PHONY: build_fast_adore-cli
build_fast_adore-cli: # build the adore-cli conte does not already exist in the docker repository. If it does exist this is a noop.
	@if [ -n "$$(docker images -q ${ADORE_CLI_PROJECT}:${ADORE_CLI_TAG})" ]; then \
        echo "Docker image: ${ADORE_CLI_PROJECT}:${ADORE_CLI_TAG} already build, skipping build."; \
    else \
        cd "${ADORE_CLI_MAKEFILE_PATH}" && make build_adore-cli;\
    fi


.PHONY: build_adore-cli
build_adore-cli: clean_adore-cli ## Builds the ADORe CLI docker context/image
	cd "${ADORE_CLI_MAKEFILE_PATH}" && make build 

.PHONY: clean_adore-cli 
clean_adore-cli: ## Clean adore-cli docker context 
	cd "${ADORE_CLI_MAKEFILE_PATH}" && make clean

.PHONY: run_test_scenarios_headless
run_test_scenarios_headless:# run headless test scenarios 
	$(eval DISPLAY_MODE := "headless")
	$(MAKE) run_test_scenarios


.PHONY: run_test_scenarios
run_test_scenarios: adore-cli_setup adore-cli_start_headless adore-cli_scenarios_run adore-cli_teardown # run test scenarios

.PHONY: adore-cli_setup
adore-cli_setup: 
	@echo "Running adore-cli setup... SOURCE_DIRECTORY: ${SOURCE_DIRECTORY}"
	make --file=${ADORE_CLI_MAKEFILE_PATH}/adore_cli.mk build_fast_adore-cli
	cd ${ADORE_CLI_SUBMODULES_PATH}/catkin_docker && make initialize_catkin_workspace
	@mkdir -p ${ADORE_CLI_SUBMODULES_PATH}/.log/.ros/bag_files
	@mkdir -p ${ADORE_CLI_SUBMODULES_PATH}/plotlabserver/.log
	@mkdir -p ${ADORE_CLI_SUBMODULES_PATH}/.log
	@cd ${ADORE_CLI_SUBMODULES_PATH}/.log && ln -sf ${ADORE_CLI_SUBMODULES_PATH}/plotlabserver/.log plotlabserver
	@touch .zsh_history
	@touch .zsh_history.new
	cd ${ADORE_CLI_SUBMODULES_PATH}/plotlabserver && \
    make down || true

.PHONY: adore-cli_teardown
adore-cli_teardown:
	@echo "Running adore-cli teardown..."
	@cd ${ADORE_CLI_MAKEFILE_PATH} && docker compose -f ${DOCKER_COMPOSE_FILE} down || true
	@cd ${ADORE_CLI_MAKEFILE_PATH} && docker compose -f ${DOCKER_COMPOSE_FILE} rm -f || true

.PHONY: adore-cli_start
adore-cli_start:
	@echo "Running adore-cli start... SOURCE_DIRECTORY: ${SOURCE_DIRECTORY}"
	cd ${ADORE_CLI_MAKEFILE_PATH} && \
    docker compose -f ${DOCKER_COMPOSE_FILE} up adore-cli_x11-display \
      --force-recreate \
      --renew-anon-volumes \
      --detach;

.PHONY: adore-cli_start_headless
adore-cli_start_headless:
	export DISPLAY_MODE=headless && make --file=${ADORE_CLI_MAKEFILE_PATH}/adore_cli.mk adore-cli_start 

.PHONY: adore-cli_attach
adore-cli_attach:
	@echo "Running adore-cli attach..."
	docker exec -it --user adore-cli adore-cli /bin/zsh -c "ADORE_CLI_WORKING_DIRECTORY=${ADORE_CLI_WORKING_DIRECTORY} bash /tmp/adore_cli/tools/adore-cli.sh" || true

.PHONY: adore-cli_scenarios_run
adore-cli_scenarios_run:
	docker exec --user adore-cli adore-cli /bin/zsh -c "ADORE_CLI_WORKING_DIRECTORY=${ADORE_CLI_WORKING_DIRECTORY} bash ${ADORE_CLI_MAKEFILE_PATH}/tools/run_test_scenarios.sh" || true

.PHONY: run_test_scenarios
run_test_scenarios: adore-cli_setup adore-cli_start_headless adore-cli_scenarios_run adore-cli_teardown ## Run adore test scenarios specified by the TEST_SCENARIOS environmental variable
	@echo "  To run alternative scenarios call 'make run_test_scenarios' by modifying the environmental variable TEST_SCENARIOS."
	@echo "    Usage examples: "
	@echo "      make run_test_scenarios TEST_SCENARIOS=baseline_test.launch"
	@echo "      make run_test_scenarios TEST_SCENARIOS=a.launch b.launch c.launch"
	@echo "      make run_test_scenarios DISPLAY_MODE=headless TEST_SCENARIOS=baseline_test.launch"
	@echo "      make run_test_scenarios DISPLAY_MODE=native TEST_SCENARIOS=baseline_test.launch"
	@echo "      make run_test_scenarios DISPLAY_MODE=window_manager TEST_SCENARIOS=baseline_test.launch"

.PHONY: image_adore-cli
image_adore-cli: ## Returns the current docker image name for adore-cli
	@echo "${ADORE_CLI_IMAGE_X11_DISPLAY}"

.PHONY: images_adore-cli
images_adore-cli: ## Returns all docker images for adore-cli
	@echo "${ADORE_CLI_IMAGE}"
	@echo "${ADORE_CLI_IMAGE_X11_DISPLAY}"

endif
