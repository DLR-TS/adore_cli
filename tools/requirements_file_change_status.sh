#!/usr/bin/env bash

BOLD='\033[1m'
BLINK='\033[5m'
ORANGE='\033[38;5;208m' 
RESET='\033[0m'

check_requirements_changes() {
    git diff --quiet --exit-code -- '**requirements*.system'
    
    if [ $? -ne 0 ]; then
        printf "  ${BOLD}${BLINK}${ORANGE}WARNING:${RESET} requirements changes. rebuild adore_cli.\n"
    fi
}

check_requirements_changes
