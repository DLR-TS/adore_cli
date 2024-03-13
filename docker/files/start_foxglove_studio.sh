#!/usr/bin/env bash

set -euo pipefail
#set -euxo pipefail #debug mode

echoerr (){ printf "%s" "$@" >&2;}
exiterr (){ printf "%s\n" "$@" >&2; exit 1;}

SCRIPT_DIRECTORY="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

PID_FILE=${SCRIPT_DIRECTORY}/.foxgolve_studio_pid

if [ -f ${PID_FILE} ]; then
    foxglove_pid=$(<${PID_FILE})
    if ps -p ${foxglove_pid} > /dev/null; then
        echo "Foxglove studio already running."
        exit 0
    fi
fi

(                                                                                                                                     set -x
cd
rm -rf ".config/Foxglove Studio"
cp ".config/foxglove_studio_config" ".config/Foxglove Studio" -r                                                                      )  

echo "Starting Foxglove studio..."
foxglove-studio 2&>1 >/dev/null &
foxgolve_studio_pid=$!
echo "${foxgolve_studio_pid}" > "${PID_FILE}" 



