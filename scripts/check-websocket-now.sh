#!/bin/bash

echo "=== Quick WebSocket Check ==="
echo ""

echo "1. Checking WebSocket server logs (last 30 lines)..."
pm2 logs worldguessr-ws --lines 30 --nostream

echo ""
echo "2. Checking what port the WebSocket server is using..."
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
echo "3. Checking if port $WS_PORT is listening..."
if command -v ss &> /dev/null; then
    ss -tuln | grep ":$WS_PORT " && echo "   ✅ Port $WS_PORT is listening" || echo "   ❌ Port $WS_PORT is NOT listening!"
elif command -v netstat &> /dev/null; then
    netstat -tuln | grep ":$WS_PORT " && echo "   ✅ Port $WS_PORT is listening" || echo "   ❌ Port $WS_PORT is NOT listening!"
fi

echo ""
echo "4. Checking Nginx WebSocket configuration..."
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
    fi
else
    echo "   ❌ Nginx config not found!"
fi

echo ""
echo "5. Testing WebSocket endpoint..."
curl -I --http1.1 --no-buffer -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Key: test" -H "Sec-WebSocket-Version: 13" https://proguessr.com/wg 2>&1 | head -5

echo ""
echo "=== To check logs in real-time: pm2 logs worldguessr-ws ==="

