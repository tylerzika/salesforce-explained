#!/bin/bash
# Script to create a scratch org
# This script assumes you've already authenticated to the Dev Hub

set -e

# Configuration
SCRATCH_ORG_ALIAS="${1:-ScratchOrg}"
SCRATCH_ORG_DURATION="${2:-7}"

echo "Creating scratch org with alias: $SCRATCH_ORG_ALIAS"
echo "Duration: $SCRATCH_ORG_DURATION days"

# Create the scratch org
sf org create scratch \
    --definition-file config/project-scratch-def.json \
    --alias "$SCRATCH_ORG_ALIAS" \
    --duration-days "$SCRATCH_ORG_DURATION" \
    --set-default \
    --no-namespace

echo "Scratch org created successfully!"

# Display org information
sf org display --target-org "$SCRATCH_ORG_ALIAS"

# Get the login URL
echo ""
echo "To open the scratch org, run:"
echo "sf org open --target-org $SCRATCH_ORG_ALIAS"
