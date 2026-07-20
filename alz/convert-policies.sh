#!/bin/bash

# Script to convert ALZ policy files in place to fix template strings
# This script converts CAF template strings to proper ALZ format

echo "Converting ALZ policy assignments to fix template strings..."

# Convert policy assignments in place
for file in ./lib/policy_assignments/*.json; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Converting: $filename"

        # Create a temporary file for the conversion
        temp_file=$(mktemp)

        # Convert template strings to proper ALZ format using a single sed command
        sed -e 's|${root_scope_resource_id}/providers/Microsoft.Authorization/policyDefinitions/|/providers/Microsoft.Authorization/policyDefinitions/|g' \
            -e 's|${root_scope_resource_id}/providers/Microsoft.Authorization/policySetDefinitions/|/providers/Microsoft.Authorization/policySetDefinitions/|g' \
            -e 's|${default_location}|canadacentral|g' \
            -e 's|${current_scope_resource_id}|/providers/Microsoft.Management/managementGroups/bcgov-managed-lz-forge|g' \
            "$file" > "$temp_file"

        # Replace the original file
        mv "$temp_file" "$file"
    fi
done

echo "Converting ALZ policy set definitions to fix template strings..."

# Convert policy set definitions in place
for file in ./lib/policy_set_definitions/*.json; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Converting: $filename"

        # Create a temporary file for the conversion
        temp_file=$(mktemp)

        # Convert template strings to proper ALZ format using a single sed command
        sed -e 's|${root_scope_resource_id}/providers/Microsoft.Authorization/policyDefinitions/|/providers/Microsoft.Authorization/policyDefinitions/|g' \
            -e 's|${root_scope_resource_id}/providers/Microsoft.Authorization/policySetDefinitions/|/providers/Microsoft.Authorization/policySetDefinitions/|g' \
            -e 's|${default_location}|canadacentral|g' \
            -e 's|${current_scope_resource_id}|/providers/Microsoft.Management/managementGroups/bcgov-managed-lz-forge|g' \
            "$file" > "$temp_file"

        # Replace the original file
        mv "$temp_file" "$file"
    fi
done

echo "Converting ALZ policy definitions to fix template strings..."

# Convert policy definitions in place
for file in ./lib/policy_definitions/*.json; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        echo "Converting: $filename"

        # Create a temporary file for the conversion
        temp_file=$(mktemp)

        # Convert template strings to proper ALZ format and add roleDefinitionIds at root level
        sed -e 's|${root_scope_resource_id}/providers/Microsoft.Authorization/policyDefinitions/|/providers/Microsoft.Authorization/policyDefinitions/|g' \
            -e 's|${root_scope_resource_id}/providers/Microsoft.Authorization/policySetDefinitions/|/providers/Microsoft.Authorization/policySetDefinitions/|g' \
            -e 's|${default_location}|canadacentral|g' \
            -e 's|${current_scope_resource_id}|/providers/Microsoft.Management/managementGroups/bcgov-managed-lz-forge|g' \
            "$file" | jq '. + {"roleDefinitionIds": []}' > "$temp_file"

        # Replace the original file
        mv "$temp_file" "$file"
    fi
done

echo "Policy conversion completed!"
