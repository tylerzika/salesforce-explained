#!/bin/bash
# Script to authenticate to Salesforce using JWT Bearer Flow
# This is typically used in CI/CD pipelines

set -e

# Check if required environment variables are set
if [ -z "$SF_USERNAME" ]; then
    echo "Error: SF_USERNAME environment variable is not set"
    exit 1
fi

if [ -z "$SF_CLIENT_ID" ]; then
    echo "Error: SF_CLIENT_ID environment variable is not set"
    exit 1
fi

if [ -z "$SF_JWT_KEY" ]; then
    echo "Error: SF_JWT_KEY environment variable is not set"
    exit 1
fi

# Create server.key file from environment variable
echo "$SF_JWT_KEY" > server.key

echo "Authenticating to Salesforce..."
sf org login jwt \
    --client-id "$SF_CLIENT_ID" \
    --jwt-key-file server.key \
    --username "$SF_USERNAME" \
    --set-default-dev-hub \
    --alias DevHub

# Clean up the key file
rm server.key

echo "Successfully authenticated to Salesforce Developer Hub!"
