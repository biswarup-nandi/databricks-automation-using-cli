#!/bin/bash

# File paths
CONFIG_FILE="$HOME/automation_project/config.json"

# Read the JSON from the config file
USER_JSON=$1

# Check if jq command was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to read JSON from $CONFIG_FILE"
  exit 1
fi

# Loop through each user in the JSON array and create them if they don't exist
echo "$USER_JSON" | while read -r user; do
  userName=$(echo "$user" | jq -r '.userName')

  # Check if user already exists by querying the user list
  existing_user=$(databricks api get /api/2.0/preview/scim/v2/Users | jq -r --arg userName "$userName" '.Resources[] | select(.userName == $userName)')

  if [ -n "$existing_user" ]; then
    user_id=$(echo "$existing_user" | jq -r '.id')
    echo "User already exists with ID: $user_id"
  else
    # Make the API call to create the user
    response=$(databricks api post /api/2.0/preview/scim/v2/Users --json "$user" -w "%{http_code}")

    # Extract the HTTP status code from the response
    status_code=$(echo "$response" | tail -n1)

    # Extract the response body (all but the last line)
    response_body=$(echo "$response" | sed '$ d')

    # Check the HTTP status code
    if [ "$status_code" -eq 201 ]; then
      # Extract the user ID from the response body
      user_id=$(echo "$response_body" | jq -r '.id')

      if [ "$user_id" != "null" ]; then
        echo "User created successfully with ID: $user_id"
      else
        echo "Failed to extract user ID from the response."
      fi
    else
      echo "Failed to create user. Response: $response_body"
    fi
  fi
done

