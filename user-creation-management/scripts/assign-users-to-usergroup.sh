#!/bin/bash

# File paths
CONFIG_FILE="$HOME/automation_project/config.json"

# Read the group JSON from the config file
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
  echo "Group found with ID: $group_id"
else
  echo "Error: Group does not exist."
  exit 1
fi

# Read the users JSON from the config file
USER_JSON=$2

# Check if jq command was successful
if [ $? -ne 0 ]; then
  echo "Error: Failed to read JSON from $CONFIG_FILE"
  exit 1
fi

# Initialize members array
members=()

# Loop through each user in the JSON array to get their IDs
echo "$USER_JSON" | while read -r user; do
  userName=$(echo "$user" | jq -r '.userName')

  # Check if user already exists by querying the user list
  existing_user=$(databricks api get /api/2.0/preview/scim/v2/Users | jq -r --arg userName "$userName" '.Resources[] | select(.userName == $userName)')

  if [ -n "$existing_user" ]; then
    user_id=$(echo "$existing_user" | jq -r '.id')
    echo "User found with ID: $user_id"
    members+=("{\"value\":\"$user_id\"}")
  else
    echo "Error: User $userName does not exist."
    exit 1
  fi
done

# Join the members array into a string
members_str=$(printf ",%s" "${members[@]}")
members_str=${members_str:1}

# Prepare the group update JSON
GROUP_UPDATE_JSON=$(jq -n --argjson members "[$members_str]" --arg id "$group_id" --arg displayName "$group_displayName" '
{
  "schemas": ["urn:ietf:params:scim:schemas:core:2.0:Group"],
  "id": $id,
  "displayName": $displayName,
  "members": $members
}')

# Make the API call to update the group with the members
response=$(databricks api put /api/2.0/preview/scim/v2/Groups/$group_id --json "$GROUP_UPDATE_JSON")

# Check if the update was successful
if [ $? -eq 0 ]; then
  echo "Users successfully assigned to group $group_displayName."
else
  echo "Failed to assign users to group. Response: $response"
fi

