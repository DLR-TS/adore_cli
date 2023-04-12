SHELL:=/bin/bash

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")

.EXPORT_ALL_VARIABLES:
#SOURCE_DIRECTORY:=$(shell realpath "${ROOT_DIR}/..")
SOURCE_DIRECTORY:=${ROOT_DIR}
ADORE_CLI_WORKING_DIRECTORY:=${ROOT_DIR}
CATKIN_WORKSPACE_DIRECTORY:=${SOURCE_DIRECTORY}/catkin_workspace

include adore_cli.mk
