#!/bin/bash

echo "=== WebSocket Connection Diagnostic ==="
echo ""

# Check what port the WebSocket server is configured to use
echo "1. Checking WebSocket server port configuration..."
if [ -f ~/worldguesser/.env.local ]; then
    WS_PORT=$(grep WS_PORT ~/worldguesser/.env.local | cut -d '=' -f2 | tr -d ' ')
    if [ -z "$WS_PORT" ]; then
        echo "   ⚠️  WS_PORT not set in .env.local, defaulting to 3002"
        WS_PORT=3002
    else
        echo "   ✅ WS_PORT found: $WS_PORT"
    fi
else
    echo "   ⚠️  .env.local not found, defaulting to 3002"
    WS_PORT=3002
fi

echo ""
echo "2. Checking if WebSocket server process is running..."
if pm2 list | grep -qE "ws|server"; then
    echo "   ✅ WebSocket process found in PM2:"
    pm2 list | grep -E "ws|server"
    echo ""
    echo "   Checking logs:"
    pm2 logs ws --lines 10 --nostream 2>/dev/null || pm2 logs server --lines 10 --nostream 2>/dev/null || echo "   No logs available"
else
    echo "   ❌ No WebSocket process found in PM2!"
fi

echo ""
echo "3. Checking if port $WS_PORT is listening..."
if command -v netstat &> /dev/null; then
    if netstat -tuln | grep -q ":$WS_PORT "; then
        echo "   ✅ Port $WS_PORT is listening"
        netstat -tuln | grep ":$WS_PORT "
    else
        echo "   ❌ Port $WS_PORT is NOT listening!"
    fi
elif command -v ss &> /dev/null; then
    if ss -tuln | grep -q ":$WS_PORT "; then
        echo "   ✅ Port $WS_PORT is listening"
        ss -tuln | grep ":$WS_PORT "
    else
        echo "   ❌ Port $WS_PORT is NOT listening!"
    fi
else
    echo "   ⚠️  Cannot check ports (netstat/ss not available)"
fi

echo ""
echo "4. Checking Nginx WebSocket configuration..."
if [ -f /etc/nginx/sites-available/worldguessr ]; then
    echo "   Checking /wg location block:"
    if grep -q "location /wg" /etc/nginx/sites-available/worldguessr; then
        echo "   ✅ /wg location found:"
        grep -A 10 "location /wg" /etc/nginx/sites-available/worldguessr | head -12
    else
        echo "   ❌ /wg location NOT found!"
    fi
    
    echo ""
    echo "   Checking ws_backend upstream:"
    if grep -q "upstream ws_backend" /etc/nginx/sites-available/worldguessr; then
        echo "   ✅ ws_backend upstream found:"
        grep -A 3 "upstream ws_backend" /etc/nginx/sites-available/worldguessr
        UPSTREAM_PORT=$(grep -A 3 "upstream ws_backend" /etc/nginx/sites-available/worldguessr | grep "server localhost:" | grep -oE "[0-9]+" | head -1)
        echo ""
        if [ "$UPSTREAM_PORT" != "$WS_PORT" ]; then
            echo "   ⚠️  MISMATCH: Nginx proxies to port $UPSTREAM_PORT but server uses $WS_PORT"
        else
            echo "   ✅ Ports match: Nginx -> $UPSTREAM_PORT, Server -> $WS_PORT"
        fi
    else
        echo "   ❌ ws_backend upstream NOT found!"
    fi
else
    echo "   ❌ Nginx config not found at /etc/nginx/sites-available/worldguessr"
fi

echo ""
echo "5. Testing WebSocket endpoint from server..."
if command -v curl &> /dev/null; then
    echo "   Testing wss://proguessr.com/wg..."
    curl -I --http1.1 --no-buffer -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Key: test" -H "Sec-WebSocket-Version: 13" https://proguessr.com/wg 2>&1 | head -10
    echo ""
    echo "   Testing localhost:$WS_PORT/wg..."
    curl -I --http1.1 --no-buffer -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Key: test" -H "Sec-WebSocket-Version: 13" http://localhost:$WS_PORT/wg 2>&1 | head -5
else
    echo "   curl not available for testing"
fi

echo ""
echo "=== Summary ==="
echo "Expected WebSocket URL: wss://proguessr.com/wg"
echo "Expected backend port: $WS_PORT"
echo ""
echo "Common issues:"
echo "  1. WebSocket server not running -> pm2 restart ws"
echo "  2. Port mismatch -> Update Nginx upstream to use port $WS_PORT"
echo "  3. Nginx not configured -> Add /wg location block"
echo "  4. Firewall blocking -> Check ufw status"

