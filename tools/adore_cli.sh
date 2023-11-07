#!/usr/bin/env bash

# This script act as the main entrypoint for the adore_cli docker context.

set -euo pipefail

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
echoerr (){ printf "%s" "$@" >&2;}
exiterr (){ echoerr "$@"; exit 1;}


#SOURCE_DIRECTORY=${SOURCE_DIRECTORY:-/tmp/adore}
ADORE_CLI_DIRECTORY=${ADORE_CLI_DIRECTORY:-/tmp/adore_cli}
#ADORE_CLI_WORKING_DIRECTORY=${SOURCE_DIRECTORY:-/tmp/adore}
#CATKIN_WORKSPACE_DIRECTORY=${CATKIN_WORKSPACE_DIRECTORY:-/tmp/adore_cli/catkin_workspace}

if [[ -z ${SOURCE_DIRECTORY+x} ]]; then
    echoerr "ERROR: The environmental variable SOURCE_DIRECTORY is empty, SOURCE_DIRECTORY must be supplied."
    echoerr "  The SOURCE_DIRECTORY is an absolute path containing catkin packages that will be soft linked into the catkin workspace."
    echo ""
    exit 1
fi

if [[ -z ${ADORE_CLI_WORKING_DIRECTORY+x} ]]; then
    echoerr "ERROR: The environmental variable ADORE_CLI_WORKING_DIRECTORY is empty, ADORE_CLI_WORKING_DIRECTORY must be supplied."
    echoerr "  The ADORE_CLI_WORKING_DIRECTORY is an absolute path where the ADORe cli will start as an initial working directory"
    echo ""
    exit 1
fi

clear

cd "${ADORE_CLI_DIRECTORY}"
bash tools/adore_cli_motd.sh

printf "\n"

#echo " SOURCE_DIRECTORY: ${SOURCE_DIRECTORY}"
#echo " ADORE_CLI_WORKING_DIRECTORY: ${ADORE_CLI_WORKING_DIRECTORY}"
#echo " CATKIN_WORKSPACE_DIRECTORY: ${CATKIN_WORKSPACE_DIRECTORY}"

cd "${ADORE_CLI_WORKING_DIRECTORY}"

if [ -z ${VEHICLE_NAME+x} ]; then 
    printf "  No vehicle set.\n\n"; 
else 
    printf "  Vehicle environment set to: ${VEHICLE_NAME}\n\n"; 
fi
zsh
