#!/bin/bash

# File paths
CONFIG_FILE="$HOME/automation_project/config.json"

# Read the group JSON from the config file based on the iteration number
ITERATION_NUMBER=$1
GROUP_JSON=$(jq -c --argjson iteration "$ITERATION_NUMBER" '.["user-management"][$iteration].groups' "$CONFIG_FILE")

# Read the users JSON from the config file based on the iteration number
USER_JSON=$(jq -c --argjson iteration "$ITERATION_NUMBER" '.["user-management"][$iteration].users[]' "$CONFIG_FILE")

# Call create-user-group.sh
"$HOME/automation_project/user-creation-management/scripts/create-user-group.sh" "$GROUP_JSON"

# Call create-user.sh
"$HOME/automation_project/user-creation-management/scripts/create-user.sh" "$USER_JSON"

# Call assign-users-to-usergroup.sh
"$HOME/automation_project/user-creation-management/scripts/assign-users-to-usergroup.sh" "$GROUP_JSON" "$USER_JSON"

