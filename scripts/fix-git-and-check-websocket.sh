#!/bin/bash

echo "=== Fixing Git and Checking WebSocket ==="
echo ""

echo "1. Resolving divergent branches..."
cd ~/worldguesser

# Check current status
echo "Current git status:"
git status --short

# Stash any local changes
echo ""
echo "Stashing any local changes..."
git stash

# Pull with merge strategy
echo ""
echo "Pulling with merge strategy..."
git pull origin master --no-rebase || {
    echo "Merge failed, trying rebase..."
    git pull origin master --rebase || {
        echo "Rebase also failed. Resetting to remote..."
        git fetch origin
        git reset --hard origin/master
    }
}

echo ""
echo "2. Checking WebSocket server status..."
pm2 list | grep -E "worldguessr-ws|ws"

echo ""
echo "3. Checking WebSocket server logs (last 20 lines)..."
pm2 logs worldguessr-ws --lines 20 --nostream

echo ""
echo "4. Checking WS_PORT configuration..."
if [ -f ~/worldguesser/.env.local ]; then
    WS_PORT=$(grep WS_PORT ~/worldguesser/.env.local | cut -d '=' -f2 | tr -d ' ' | tr -d '"')
    if [ -z "$WS_PORT" ]; then
        echo "   ⚠️  WS_PORT not set, default is 3002"
        WS_PORT=3002
    else
        echo "   ✅ WS_PORT: $WS_PORT"
    fi
else
    echo "   ⚠️  .env.local not found, default is 3002"
    WS_PORT=3002
fi

echo ""
echo "5. Checking if port $WS_PORT is listening..."
if command -v ss &> /dev/null; then
    if ss -tuln | grep -q ":$WS_PORT "; then
        echo "   ✅ Port $WS_PORT is listening"
        ss -tuln | grep ":$WS_PORT "
    else
        echo "   ❌ Port $WS_PORT is NOT listening!"
    fi
elif command -v netstat &> /dev/null; then
    if netstat -tuln | grep -q ":$WS_PORT "; then
        echo "   ✅ Port $WS_PORT is listening"
        netstat -tuln | grep ":$WS_PORT "
    else
        echo "   ❌ Port $WS_PORT is NOT listening!"
    fi
fi

echo ""
echo "6. Checking Nginx WebSocket configuration..."
if [ -f /etc/nginx/sites-available/worldguessr ]; then
    echo "   Upstream ws_backend:"
    grep -A 3 "upstream ws_backend" /etc/nginx/sites-available/worldguessr || echo "   ❌ ws_backend upstream not found!"
    
    echo ""
    echo "   Location /wg:"
    grep -A 10 "location /wg" /etc/nginx/sites-available/worldguessr | head -12 || echo "   ❌ /wg location not found!"
    
    # Check for port mismatch
    UPSTREAM_PORT=$(grep -A 3 "upstream ws_backend" /etc/nginx/sites-available/worldguessr | grep "server localhost:" | grep -oE "[0-9]+" | head -1)
    if [ ! -z "$UPSTREAM_PORT" ] && [ "$UPSTREAM_PORT" != "$WS_PORT" ]; then
        echo ""
        echo "   ⚠️  PORT MISMATCH DETECTED!"
        echo "   Nginx proxies to: localhost:$UPSTREAM_PORT"
        echo "   Server listens on: localhost:$WS_PORT"
        echo "   This will cause connection failures!"
        echo ""
        echo "   To fix, update Nginx config:"
        echo "   sudo nano /etc/nginx/sites-available/worldguessr"
        echo "   Change 'server localhost:$UPSTREAM_PORT' to 'server localhost:$WS_PORT'"
    elif [ ! -z "$UPSTREAM_PORT" ]; then
        echo ""
        echo "   ✅ Ports match: Nginx -> $UPSTREAM_PORT, Server -> $WS_PORT"
    fi
else
    echo "   ❌ Nginx config not found!"
fi

echo ""
echo "7. Testing WebSocket endpoint..."
curl -I --http1.1 --no-buffer -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Key: test" -H "Sec-WebSocket-Version: 13" https://proguessr.com/wg 2>&1 | head -5

echo ""
echo "=== Done ==="
echo "To check logs in real-time: pm2 logs worldguessr-ws"

