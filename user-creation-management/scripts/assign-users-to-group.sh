#!/bin/bash

# Function to assign users to group
assign_users_to_group() {
    group_id="$1"
    user_ids=("${@:2}")
    # Assign users to group
    for user_id in "${user_ids[@]}"; do
        databricks api post /api/2.0/preview/scim/v2/Groups/"$group_id" --json "$(dirname "$0")/../../config.json"
    done
}

