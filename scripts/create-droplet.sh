#!/bin/bash

# DigitalOcean Droplet Creation Script
# This script creates a droplet via the DigitalOcean API

set -e

# Check if token is set
if [ -z "$DO_TOKEN" ]; then
    echo "❌ Error: DO_TOKEN environment variable is not set"
    echo ""
    echo "To get your API token:"
    echo "1. Go to https://cloud.digitalocean.com/account/api/tokens"
    echo "2. Click 'Generate New Token'"
    echo "3. Give it a name (e.g., 'worldguessr-deploy')"
    echo "4. Copy the token"
    echo ""
    echo "Then run:"
    echo "  export DO_TOKEN=your_token_here"
    echo "  ./scripts/create-droplet.sh"
    exit 1
fi

# Configuration
DROPLET_NAME="${DROPLET_NAME:-worldguessr-production}"
DROPLET_SIZE="${DROPLET_SIZE:-s-2vcpu-2gb}"  # $12/month
DROPLET_REGION="${DROPLET_REGION:-sfo2}"      # San Francisco
DROPLET_IMAGE="${DROPLET_IMAGE:-ubuntu-22-04-x64}"  # Ubuntu 22.04 LTS

echo "🚀 Creating DigitalOcean Droplet..."
echo ""
echo "Configuration:"
echo "  Name: $DROPLET_NAME"
echo "  Size: $DROPLET_SIZE"
echo "  Region: $DROPLET_REGION"
echo "  Image: $DROPLET_IMAGE"
echo ""

# Create droplet
RESPONSE=$(curl -s -X POST \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $DO_TOKEN" \
    -d "{
        \"name\": \"$DROPLET_NAME\",
        \"size\": \"$DROPLET_SIZE\",
        \"region\": \"$DROPLET_REGION\",
        \"image\": \"$DROPLET_IMAGE\",
        \"ssh_keys\": [],
        \"backups\": false,
        \"ipv6\": false,
        \"monitoring\": false,
        \"tags\": [\"worldguessr\"]
    }" \
    "https://api.digitalocean.com/v2/droplets")

# Check for errors
if echo "$RESPONSE" | grep -q '"id"'; then
    DROPLET_ID=$(echo "$RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
    echo "✅ Droplet created successfully!"
    echo ""
    echo "Droplet ID: $DROPLET_ID"
    echo ""
    echo "⏳ Waiting for droplet to be ready (this may take 1-2 minutes)..."
    
    # Wait for droplet to be active
    STATUS="new"
    while [ "$STATUS" != "active" ]; do
        sleep 5
        DROPLET_INFO=$(curl -s -X GET \
            -H "Authorization: Bearer $DO_TOKEN" \
            "https://api.digitalocean.com/v2/droplets/$DROPLET_ID")
        STATUS=$(echo "$DROPLET_INFO" | grep -o '"status":"[^"]*"' | head -1 | cut -d'"' -f4)
        echo "  Status: $STATUS"
    done
    
    # Get IP address
    DROPLET_IP=$(echo "$DROPLET_INFO" | grep -o '"ip_address":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    echo ""
    echo "🎉 Droplet is ready!"
    echo ""
    echo "IP Address: $DROPLET_IP"
    echo ""
    echo "Next steps:"
    echo "1. SSH into your droplet:"
    echo "   ssh root@$DROPLET_IP"
    echo ""
    echo "2. Follow the deployment guide:"
    echo "   docs/digitalocean-quickstart.md"
    echo ""
    echo "3. Save this information:"
    echo "   Droplet ID: $DROPLET_ID"
    echo "   IP Address: $DROPLET_IP"
    
else
    echo "❌ Error creating droplet:"
    echo "$RESPONSE" | grep -o '"message":"[^"]*"' | head -1 | cut -d'"' -f4 || echo "$RESPONSE"
    exit 1
fi

