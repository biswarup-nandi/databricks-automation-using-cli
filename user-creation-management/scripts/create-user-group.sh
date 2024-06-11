#!/bin/bash

# File paths
CONFIG_FILE="$HOME/automation_project/config.json"

# Read the JSON from the config file
GROUP_JSON=$1

# Check if jq command was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to read JSON from $CONFIG_FILE"
  exit 1
fi

# Extract the displayName of the group
group_displayName=$(echo "$GROUP_JSON" | jq -r '.displayName')

# Check if the group already exists by querying the group list
existing_group=$(databricks api get /api/2.0/preview/scim/v2/Groups | jq -r --arg group_displayName "$group_displayName" '.Resources[] | select(.displayName == $group_displayName)')

if [ -n "$existing_group" ]; then
  group_id=$(echo "$existing_group" | jq -r '.id')
  echo "Group already exists with ID: $group_id"
else
  # Make the API call to create the group
  response=$(databricks api post /api/2.0/preview/scim/v2/Groups --json "$GROUP_JSON" -w "%{http_code}")

  # Extract the HTTP status code from the response
  status_code=$(echo "$response" | tail -n1)

  # Extract the response body (all but the last line)
  response_body=$(echo "$response" | sed '$ d')

  # Check the HTTP status code
  if [ "$status_code" -eq 201 ]; then
    # Extract the group ID from the response body
    group_id=$(echo "$response_body" | jq -r '.id')

    if [ "$group_id" != "null" ]; then
      echo "Group created successfully with ID: $group_id"
    else
      echo "Failed to extract group ID from the response."
    fi
  else
    echo "Failed to create group. Response: $response_body"
  fi
fi

