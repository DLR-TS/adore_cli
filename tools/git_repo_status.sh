#!/usr/bin/env bash

set -euo pipefail

echoerr (){ printf "%s" "$@" >&2;}
exiterr (){ printf "%s\n" "$@" >&2; exit 1;}

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

BOLD='\033[1m'
BLINK='\033[5m'
ORANGE='\033[38;5;208m' 
RESET='\033[0m'

(
cd ${SCRIPT_DIRECTORY}
if [ ! -z "$(git status --porcelain)" ]; then
    printf "  ${BOLD}${BLINK}${ORANGE}WARNING:${RESET} The ${BOLD}adore_cli${RESET} repo has changes. \n  Rebuild the adore_cli with 'make build_adore_cli' for new changes to take effect.\n"
    printf "  Commit or discard changes to the adore_cli repo to clear this message.\n\n"
    #git status
    echo ""
fi
)
