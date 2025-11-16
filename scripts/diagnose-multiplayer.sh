#!/bin/bash
# Multiplayer Connection Diagnostic Script

echo "🔍 Diagnosing Multiplayer Connection Issues..."
echo ""

# Check if on server or local
if [ -f "/etc/nginx/sites-available/worldguessr" ]; then
    echo "✅ Running on server"
    SERVER_MODE=true
else
    echo "ℹ️  Running locally"
    SERVER_MODE=false
fi

echo ""
echo "1️⃣ Checking PM2 Services..."
pm2 status | grep -E "worldguessr|NAME"
echo ""

if [ "$SERVER_MODE" = true ]; then
    echo "2️⃣ Checking WebSocket Server Logs (last 20 lines)..."
    pm2 logs worldguessr-ws --lines 20 --nostream
    echo ""
    
    echo "3️⃣ Checking Nginx Configuration..."
    if sudo nginx -t 2>&1 | grep -q "successful"; then
        echo "✅ Nginx configuration is valid"
    else
        echo "❌ Nginx configuration has errors:"
        sudo nginx -t
    fi
    echo ""
    
    echo "4️⃣ Checking WebSocket Port..."
    WS_PORT=$(grep -E "WS_PORT|ws_port" ~/worldguesser/.env.local ~/worldguesser/.env 2>/dev/null | head -1 | cut -d'=' -f2 | tr -d ' ')
    if [ -z "$WS_PORT" ]; then
        WS_PORT=8002
        echo "⚠️  WS_PORT not found in env, defaulting to 8002"
    fi
    echo "WebSocket port: $WS_PORT"
    
    if netstat -tuln 2>/dev/null | grep -q ":$WS_PORT "; then
        echo "✅ Port $WS_PORT is listening"
    else
        echo "❌ Port $WS_PORT is NOT listening"
    fi
    echo ""
    
    echo "5️⃣ Checking Environment Variables..."
    if [ -f ~/worldguesser/.env.local ]; then
        echo "Found .env.local:"
        grep -E "NEXT_PUBLIC_WS_HOST|NEXT_PUBLIC_API_URL|WS_PORT" ~/worldguesser/.env.local | sed 's/=.*/=***/' || echo "⚠️  No WebSocket env vars found"
    else
        echo "⚠️  .env.local not found"
    fi
    echo ""
    
    echo "6️⃣ Testing WebSocket Endpoint..."
    echo "Testing: wss://proguessr.com/wg"
    curl -I -N \
      -H "Connection: Upgrade" \
      -H "Upgrade: websocket" \
      -H "Sec-WebSocket-Version: 13" \
      -H "Sec-WebSocket-Key: test" \
      https://proguessr.com/wg 2>&1 | head -5
    echo ""
fi

echo "7️⃣ Quick Fixes to Try:"
echo "   - Restart WebSocket: pm2 restart worldguessr-ws"
echo "   - Reload Nginx: sudo systemctl reload nginx"
echo "   - Check logs: pm2 logs worldguessr-ws"
echo ""

