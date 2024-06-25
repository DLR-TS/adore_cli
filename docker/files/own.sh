#!/usr/bin/env bash

set -euo pipefail
#set -euxo pipefail #debug mode

echoerr() { printf "%s\n" "$@" >&2; }
exiterr() { printf "%s\n" "$@" >&2; exit 1; }

if [ "$#" -ne 3 ]; then
  exiterr "Usage: $0 NEW_USER NEW_UID NEW_GID"
fi

NEW_USER=$1
NEW_UID=$2
NEW_GID=$3

SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

ORIGINAL_USER="$(find /home -mindepth 1 -maxdepth 1 -type d -print -quit | sed 's|/home/||' | tr -d '\n')"

if [ -z "${ORIGINAL_USER}" ]; then
  exiterr "No original user found in /home"
fi

echo "Original user: ${ORIGINAL_USER}"
echo "New user: ${NEW_USER}"

echo "Moving home directory..."
tar -czf "/home/${ORIGINAL_USER}.tar.gz" "/home/${ORIGINAL_USER}"

if [[ -d "/home/${NEW_USER}" ]]; then
    echo "Home directory for ${NEW_USER} already exists. Skipping move operation."
else
    echo "Moving home directory..."
    mv "/home/${ORIGINAL_USER}" "/home/${NEW_USER}"
    echo "Home directory moved from /home/${ORIGINAL_USER} to /home/${NEW_USER}"
fi

echo "Deleting user"
userdel "${ORIGINAL_USER}" || true

# Creating or updating the group
if getent group "${NEW_USER}" > /dev/null; then
  groupmod -g "${NEW_GID}" "${NEW_USER}"
else
  groupadd -g "${NEW_GID}" "${NEW_USER}"
fi

# Creating or updating the user with specified UID and GID
if id "${NEW_USER}" &>/dev/null; then
  usermod -u "${NEW_UID}" -g "${NEW_GID}" -d "/home/${NEW_USER}" -s /bin/bash "${NEW_USER}"
else
  useradd -M -d /home/"${NEW_USER}" -u "${NEW_UID}" -g "${NEW_GID}" -s /bin/bash "${NEW_USER}"
fi

# Changing ownership of the renamed home directory recursively
echo "Taking ownership of home directory..."
chown -R ${NEW_USER}:${NEW_USER} /home/${NEW_USER}

echo "User ${ORIGINAL_USER} has been replaced by ${NEW_USER} with UID=${NEW_UID} and GID=${NEW_GID}"

