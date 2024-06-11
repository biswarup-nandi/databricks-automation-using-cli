#!/bin/bash

# File paths
CONFIG_FILE="$HOME/automation_project/config.json"
USER_MANAGEMENT_ARRAY=$(jq '.["user-management"] | length' "$CONFIG_FILE")

# Check if jq command was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to read JSON from $CONFIG_FILE"
  exit 1
fi

# Loop through each element in the "user-management" array
for ((i=0; i<$USER_MANAGEMENT_ARRAY; i++)); do
  echo "Executing user management iteration $i..."
  "$HOME/automation_project/user-creation-management/user-creation-management.sh" $i
done

echo "All user management iterations completed."

