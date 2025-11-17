#!/bin/bash
# Comprehensive Multiplayer Connection Fix Script
# Run this on your DigitalOcean server

set -e

echo "🔧 Fixing Multiplayer Connection Issues..."
echo ""

cd ~/worldguesser

# Step 1: Check and set environment variables
echo "1️⃣ Checking environment variables..."
if [ ! -f .env.local ]; then
    echo "Creating .env.local..."
    touch .env.local
fi

# Add/update WebSocket environment variables
if ! grep -q "NEXT_PUBLIC_API_URL" .env.local 2>/dev/null; then
    echo "NEXT_PUBLIC_API_URL=proguessr.com" >> .env.local
    echo "✅ Added NEXT_PUBLIC_API_URL"
fi

if ! grep -q "NEXT_PUBLIC_WS_HOST" .env.local 2>/dev/null; then
    echo "NEXT_PUBLIC_WS_HOST=proguessr.com" >> .env.local
    echo "✅ Added NEXT_PUBLIC_WS_HOST"
fi

if ! grep -q "WS_PORT" .env.local 2>/dev/null; then
    echo "WS_PORT=8002" >> .env.local
    echo "✅ Added WS_PORT"
fi

echo "Current environment variables:"
grep -E "NEXT_PUBLIC_WS_HOST|NEXT_PUBLIC_API_URL|WS_PORT" .env.local || echo "⚠️  No WebSocket env vars found"
echo ""

# Step 2: Check PM2 services
echo "2️⃣ Checking PM2 services..."
pm2 status
echo ""

# Step 3: Restart WebSocket server
echo "3️⃣ Restarting WebSocket server..."
pm2 restart worldguessr-ws 2>/dev/null || pm2 start ecosystem.config.cjs --only worldguessr-ws
pm2 save
sleep 2
pm2 status worldguessr-ws
echo ""

# Step 4: Check if WebSocket server is listening
echo "4️⃣ Checking if WebSocket server is listening on port 8002..."
if netstat -tuln 2>/dev/null | grep -q ":8002 "; then
    echo "✅ Port 8002 is listening"
else
    echo "❌ Port 8002 is NOT listening - WebSocket server may not be running"
    echo "Checking logs..."
    pm2 logs worldguessr-ws --lines 10 --nostream
fi
echo ""

# Step 5: Check Nginx configuration
echo "5️⃣ Checking Nginx WebSocket configuration..."
if sudo nginx -t 2>&1 | grep -q "successful"; then
    echo "✅ Nginx configuration is valid"
    
    # Check if /wg location exists in Nginx config
    if sudo grep -q "location /wg" /etc/nginx/sites-available/worldguessr 2>/dev/null; then
        echo "✅ WebSocket location /wg found in Nginx config"
    else
        echo "⚠️  WebSocket location /wg NOT found in Nginx config"
        echo "Adding WebSocket configuration..."
        
        # Backup current config
        sudo cp /etc/nginx/sites-available/worldguessr /etc/nginx/sites-available/worldguessr.backup.$(date +%Y%m%d_%H%M%S)
        
        # Check if ws_backend upstream exists
        if ! sudo grep -q "upstream ws_backend" /etc/nginx/sites-available/worldguessr 2>/dev/null; then
            echo "Adding ws_backend upstream..."
            sudo sed -i '/upstream api_backend {/a upstream ws_backend {\n    server localhost:8002;\n}' /etc/nginx/sites-available/worldguessr
        fi
        
        # Add WebSocket location if it doesn't exist
        if ! sudo grep -q "location /wg" /etc/nginx/sites-available/worldguessr 2>/dev/null; then
            echo "Adding /wg location block..."
            sudo sed -i '/location \/api\/ {/a \n    location /wg {\n        proxy_pass http://ws_backend;\n        proxy_http_version 1.1;\n        proxy_set_header Upgrade $http_upgrade;\n        proxy_set_header Connection $connection_upgrade;\n        proxy_set_header Host $host;\n        proxy_set_header X-Real-IP $remote_addr;\n        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;\n        proxy_set_header X-Forwarded-Proto $scheme;\n    }' /etc/nginx/sites-available/worldguessr
        fi
        
        # Test and reload
        if sudo nginx -t; then
            sudo systemctl reload nginx
            echo "✅ Nginx reloaded with WebSocket configuration"
        else
            echo "❌ Nginx configuration error - restoring backup"
            sudo cp /etc/nginx/sites-available/worldguessr.backup.* /etc/nginx/sites-available/worldguessr
        fi
    fi
    
    sudo systemctl reload nginx
    echo "✅ Nginx reloaded"
else
    echo "❌ Nginx configuration has errors:"
    sudo nginx -t
fi
echo ""

# Step 6: Check WebSocket server logs
echo "6️⃣ Checking WebSocket server logs (last 20 lines)..."
pm2 logs worldguessr-ws --lines 20 --nostream
echo ""

# Step 7: Test WebSocket endpoint locally
echo "7️⃣ Testing WebSocket endpoint locally..."
if curl -I http://localhost:8002/ 2>&1 | head -1 | grep -q "200\|101\|426"; then
    echo "✅ WebSocket server responds locally"
else
    echo "⚠️  WebSocket server may not be responding locally"
fi
echo ""

# Step 8: Rebuild frontend with new env vars
echo "8️⃣ Rebuilding frontend with updated environment variables..."
npm run build
echo ""

# Step 9: Restart all services
echo "9️⃣ Restarting all services..."
pm2 restart all
pm2 save
echo ""

# Step 10: Final status check
echo "🔟 Final status check..."
echo "PM2 Status:"
pm2 status
echo ""
echo "WebSocket port check:"
netstat -tuln 2>/dev/null | grep ":8002 " || echo "⚠️  Port 8002 not found"
echo ""

echo "✅ Multiplayer fix complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Visit https://proguessr.com"
echo "   2. Open browser console (F12)"
echo "   3. Try connecting to multiplayer"
echo "   4. Check console for WebSocket connection errors"
echo "   5. If still having issues, run: pm2 logs worldguessr-ws --lines 50"
echo ""
echo "🔍 To test WebSocket connection manually:"
echo "   curl -i -N -H 'Connection: Upgrade' -H 'Upgrade: websocket' -H 'Sec-WebSocket-Version: 13' -H 'Sec-WebSocket-Key: test' https://proguessr.com/wg"

