#!/bin/bash

# Quick droplet creation using curl
# Usage: DO_TOKEN=your_token ./scripts/create-droplet-curl.sh

if [ -z "$DO_TOKEN" ]; then
    echo "Error: DO_TOKEN not set"
    echo "Usage: DO_TOKEN=your_token ./scripts/create-droplet-curl.sh"
    exit 1
fi

curl -X POST \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $DO_TOKEN" \
    -d '{
        "name":"worldguessr-production",
        "size":"s-2vcpu-2gb",
        "region":"sfo2",
        "image":"ubuntu-22-04-x64"
    }' \
    "https://api.digitalocean.com/v2/droplets"

echo ""
echo "✅ Droplet creation request sent!"
echo "Check status at: https://cloud.digitalocean.com/droplets"

