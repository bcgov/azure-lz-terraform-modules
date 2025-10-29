#!/bin/bash

# Read the template file
template_content=$(cat "${1}")

# Replace template variables
processed_content=$(echo "$template_content" | sed "s/\${root_id}/${2}/g" | sed "s/\${root_display_name}/${3}/g")

# Write the processed content to the expected location
echo "$processed_content" > "${4}"

# Return JSON for the data source
echo '{"status": "success", "root_id": "'${2}'", "root_display_name": "'${3}'"}'
