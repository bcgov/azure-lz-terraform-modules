#!/bin/bash

# Set your subscription ID, resource group name, and firewall policy name
subscriptionId="09bd024b-fbda-417d-b8db-694680c2b44e"
resourceGroupName="bcgov-managed-lz-forge-connectivity"
firewallPolicyName="bcgov-managed-lz-forge-fw-hub-canadacentral-policy"
apiVersion="2024-01-01"

initial_filter='{
        "filters": [
            {"field":"Severity", "values": ["Medium"]},
            {"field":"Mode", "values": ["Alert"]},
            {"field":"Direction", "values": [1]}
        ],
        "search": "",
        "orderBy": {"field":"signatureId", "order":"Ascending"},
    }'

# Use the Azure CLI to make the initial API request and store the response in a variable
response=$(az rest --method post --uri "https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/firewallPolicies/${firewallPolicyName}/listIdpsSignatures?api-version=${apiVersion}" --body "$initial_filter")

# Parse the initial response JSON and store the matchingRecordsCount in a variable
matchingRecordsCount=$(echo $response | jq -r '.matchingRecordsCount')

# Calculate the number of iterations based on matchingRecordsCount divided by 1000
iterations=$((matchingRecordsCount / 1000))

# Initialize variables for skip and limit
skip=0
limit=1000  # Adjust this value as needed

# Loop through the API requests
for ((i = 0; i <= iterations; i++)); do
    # Create the request body JSON with updated skip value
    request_body='{
        "filters": [
            {"field":"Severity", "values": ["High", "Medium"]},
            {"field":"Mode", "values": ["Alert"]}
        ],
        "search": "",
        "orderBy": {"field":"signatureId", "order":"Ascending"},
        "skip": '$skip'
    }'

    # Make the API request with the updated request body and store the response
    response=$(az rest --method post --uri "https://management.azure.com/subscriptions/${subscriptionId}/resourceGroups/${resourceGroupName}/providers/Microsoft.Network/firewallPolicies/${firewallPolicyName}/listIdpsSignatures?api-version=${apiVersion}" --body "$request_body")

    # Create a unique filename for each JSON file based on the iteration
    filename="results_$i.json"

    # Write the response to the JSON file
    echo $response > $filename

    # Increment the skip value for the next iteration
    skip=$((skip + limit))
done
