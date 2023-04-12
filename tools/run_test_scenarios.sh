#!/usr/bin/env bash

function echoerr { echo "$@" >&2; exit 1;}


SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]:-$0}"; )" &> /dev/null && pwd 2> /dev/null; )";

ADORE_CLI_DIRECTORY=${ADORE_CLI_DIRECTORY:-/tmp/adore_cli}

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

if [[ -z ${CATKIN_WORKSPACE_DIRECTORY+x} ]]; then
    echoerr "ERROR: The environmental variable CATKIN_WORKSPACE_DIRECTORY is empty, CATKIN_WORKSPACE_DIRECTORY must be supplied."
    echoerr "  The CATKIN_WORKSPACE_DIRECTORY is an absolute path to a catkin workspace."
    echo ""
    exit 1
fi

PLOTLABSERVER_DIRECTORY=${PLOTLABSERVER_DIRECTORY:-${SOURCE_DIRECTORY}/plotlabserver}
LOG_DIR="${SOURCE_DIRECTORY}/.log"
ROS_LOG_DIR="${LOG_DIR}/.ros/log"
PLOTLABSERVER_LOG_DIR="${LOG_DIR}/plotlabserver"



clear
cd ${SCRIPT_DIR}/.. 


bash "${SCRIPT_DIR}/wait_for_plotlab_server.sh"

echo ""
printf "  Waiting for catkin workspace ..."
until [ -e "${CATKIN_WORKSPACE_DIRECTORY}/install/setup.sh" ]; do
    printf "."
    sleep 1
done
printf " done \n"
source "${CATKIN_WORKSPACE_DIRECTORY}/install/setup.sh"



cd "${SOURCE_DIRECTORY}/adore_if_ros_demos"

for test_scenario in $TEST_SCENARIOS; do
    if [[ ! -f "${test_scenario}" ]]; then
        echoerr "ERROR: Specified test scenario: ${test_scenario} is not found."
    fi

    scenario_name=$(basename "${test_scenario}" .launch)
    scenario_log_dir="${LOG_DIR}/scenario_logs/${scenario_name}"
    mkdir -p "${scenario_log_dir}/.ros"
    mkdir -p "${scenario_log_dir}/plotlabserver"
    echo "Running scenario: ${test_scenario}"
    BAG_OUTPUT_DIRECTORY="${scenario_log_dir}" roslaunch "${test_scenario}"
    cd "${ROS_LOG_DIR}"
    latest_ros_log_path="$(ls -t | head -1)"
    rm latest -f
    ln -s -f "${latest_ros_log_path}" latest 2> /dev/null || true
    ln -s -f "${latest_ros_log_path}" "${scenario_name}" 2> /dev/null || true
    mkdir -p "${LOG_DIR}/${scenario_name}/.ros"
    cp -r "${ROS_LOG_DIR}/${scenario_name}"/* "${scenario_log_dir}/.ros/"
    (cd "${PLOTLABSERVER_LOG_DIR}" && cp -r * "${scenario_log_dir}/plotlabserver")
    cd "${scenario_log_dir}" && ln -s .ros ros_logs
done
