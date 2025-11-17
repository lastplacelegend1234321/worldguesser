#!/bin/bash
# Complete Multiplayer Fix Script - Based on Original Repo Implementation
# Run this on your DigitalOcean server

set -e

echo "🔧 Fixing Multiplayer Connection (Original Repo Method)..."
echo ""

cd ~/worldguesser

# Step 1: Ensure environment variables are set correctly
echo "1️⃣ Setting environment variables..."
if [ ! -f .env.local ]; then
    touch .env.local
fi

# Set NEXT_PUBLIC_API_URL (required for API calls)
if ! grep -q "NEXT_PUBLIC_API_URL" .env.local 2>/dev/null; then
    echo "NEXT_PUBLIC_API_URL=proguessr.com" >> .env.local
    echo "✅ Added NEXT_PUBLIC_API_URL=proguessr.com"
fi

# Set NEXT_PUBLIC_WS_HOST (required for WebSocket)
if ! grep -q "NEXT_PUBLIC_WS_HOST" .env.local 2>/dev/null; then
    echo "NEXT_PUBLIC_WS_HOST=proguessr.com" >> .env.local
    echo "✅ Added NEXT_PUBLIC_WS_HOST=proguessr.com"
fi

# Set WS_PORT for WebSocket server
if ! grep -q "WS_PORT" .env.local 2>/dev/null; then
    echo "WS_PORT=8002" >> .env.local
    echo "✅ Added WS_PORT=8002"
fi

echo "Current environment variables:"
grep -E "NEXT_PUBLIC_WS_HOST|NEXT_PUBLIC_API_URL|WS_PORT" .env.local
echo ""

# Step 2: Verify PM2 services
echo "2️⃣ Checking PM2 services..."
pm2 status
echo ""

# Step 3: Restart WebSocket server
echo "3️⃣ Restarting WebSocket server..."
pm2 restart worldguessr-ws 2>/dev/null || pm2 start ecosystem.config.cjs --only worldguessr-ws
pm2 save
sleep 3
echo "PM2 status after restart:"
pm2 status worldguessr-ws
echo ""

# Step 4: Check if WebSocket server is listening
echo "4️⃣ Checking if WebSocket server is listening..."
if netstat -tuln 2>/dev/null | grep -q ":8002 "; then
    echo "✅ Port 8002 is listening"
else
    echo "❌ Port 8002 is NOT listening"
    echo "Checking WebSocket server logs..."
    pm2 logs worldguessr-ws --lines 20 --nostream
fi
echo ""

# Step 5: Verify Nginx WebSocket configuration
echo "5️⃣ Verifying Nginx WebSocket configuration..."
if sudo grep -q "location /wg" /etc/nginx/sites-available/worldguessr 2>/dev/null; then
    echo "✅ WebSocket location /wg found"
    sudo grep -A 10 "location /wg" /etc/nginx/sites-available/worldguessr | head -12
else
    echo "❌ WebSocket location /wg NOT found - adding it..."
    
    # Backup config
    sudo cp /etc/nginx/sites-available/worldguessr /etc/nginx/sites-available/worldguessr.backup.$(date +%Y%m%d_%H%M%S)
    
    # Add ws_backend upstream if missing
    if ! sudo grep -q "upstream ws_backend" /etc/nginx/sites-available/worldguessr 2>/dev/null; then
        sudo sed -i '/upstream api_backend {/a upstream ws_backend {\n    server localhost:8002;\n}' /etc/nginx/sites-available/worldguessr
        echo "✅ Added ws_backend upstream"
    fi
    
    # Add /wg location block
    if ! sudo grep -q "location /wg" /etc/nginx/sites-available/worldguessr 2>/dev/null; then
        sudo sed -i '/location \/api\/ {/a \n    location /wg {\n        proxy_pass http://ws_backend;\n        proxy_http_version 1.1;\n        proxy_set_header Upgrade $http_upgrade;\n        proxy_set_header Connection $connection_upgrade;\n        proxy_set_header Host $host;\n        proxy_set_header X-Real-IP $remote_addr;\n        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n        proxy_set_header X-Forwarded-Proto $scheme;\n    }' /etc/nginx/sites-available/worldguessr
        echo "✅ Added /wg location block"
    fi
    
    # Test and reload
    if sudo nginx -t; then
        sudo systemctl reload nginx
        echo "✅ Nginx reloaded"
    else
        echo "❌ Nginx config error - restoring backup"
        sudo cp /etc/nginx/sites-available/worldguessr.backup.* /etc/nginx/sites-available/worldguessr
    fi
fi
echo ""

# Step 6: Test WebSocket endpoint locally
echo "6️⃣ Testing WebSocket endpoint locally..."
if curl -I http://localhost:8002/ 2>&1 | head -1 | grep -q "200\|101\|426"; then
    echo "✅ WebSocket server responds locally"
else
    echo "⚠️  WebSocket server may not be responding locally"
fi
echo ""

# Step 7: Rebuild frontend with correct env vars
echo "7️⃣ Rebuilding frontend..."
npm run build
echo ""

# Step 8: Restart all services
echo "8️⃣ Restarting all services..."
pm2 restart all
pm2 save
echo ""

# Step 9: Final checks
echo "9️⃣ Final status check..."
echo "PM2 Status:"
pm2 status
echo ""
echo "WebSocket port:"
netstat -tuln 2>/dev/null | grep ":8002 " || echo "⚠️  Port 8002 not found"
echo ""
echo "Environment variables in use:"
grep -E "NEXT_PUBLIC_WS_HOST|NEXT_PUBLIC_API_URL|WS_PORT" .env.local
echo ""

echo "✅ Multiplayer fix complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Visit https://proguessr.com"
echo "   2. Open browser console (F12)"
echo "   3. Try connecting to multiplayer"
echo "   4. Check console for WebSocket URL being used"
echo "   5. Expected URL: wss://proguessr.com/wg"
echo ""
echo "🔍 To test WebSocket manually:"
echo "   curl -i -N -H 'Connection: Upgrade' -H 'Upgrade: websocket' -H 'Sec-WebSocket-Version: 13' -H 'Sec-WebSocket-Key: test' https://proguessr.com/wg"
echo ""
echo "📊 To check WebSocket server logs:"
echo "   pm2 logs worldguessr-ws --lines 50"

