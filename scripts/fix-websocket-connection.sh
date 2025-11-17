#!/bin/bash

echo "=== WebSocket Connection Diagnostic & Fix ==="
echo ""

# Check PM2 processes
echo "1. Checking PM2 processes..."
pm2 list

echo ""
echo "2. Checking WebSocket server logs..."
pm2 logs ws --lines 20 --nostream 2>/dev/null || pm2 logs server --lines 20 --nostream 2>/dev/null || echo "   No WebSocket logs found"

echo ""
echo "3. Checking if WebSocket port is listening..."
WS_PORT=${WS_PORT:-8002}
if command -v netstat &> /dev/null; then
    netstat -tuln | grep -E ":${WS_PORT}|:3002" || echo "   No process listening on WebSocket ports"
elif command -v ss &> /dev/null; then
    ss -tuln | grep -E ":${WS_PORT}|:3002" || echo "   No process listening on WebSocket ports"
else
    echo "   Cannot check ports (netstat/ss not available)"
fi

echo ""
echo "4. Checking Nginx WebSocket configuration..."
if [ -f /etc/nginx/sites-available/worldguessr ]; then
    echo "   Checking /wg location block:"
    grep -A 15 "location /wg" /etc/nginx/sites-available/worldguessr || echo "   ❌ No /wg location block found!"
    
    echo ""
    echo "   Checking upstream ws_backend:"
    grep -A 5 "upstream ws_backend" /etc/nginx/sites-available/worldguessr || echo "   ❌ No ws_backend upstream found!"
else
    echo "   ❌ Nginx config not found at /etc/nginx/sites-available/worldguessr"
fi

echo ""
echo "5. Testing WebSocket endpoint..."
if command -v curl &> /dev/null; then
    echo "   Testing wss://proguessr.com/wg..."
    curl -I --http1.1 --no-buffer -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Key: test" -H "Sec-WebSocket-Version: 13" https://proguessr.com/wg 2>&1 | head -10
else
    echo "   curl not available for testing"
fi

echo ""
echo "=== Attempting Fixes ==="
echo ""

# Restart WebSocket server
echo "6. Restarting WebSocket server..."
pm2 restart ws 2>/dev/null || pm2 restart server 2>/dev/null || echo "   Could not restart WebSocket process"

# If ws process doesn't exist, try to start it
if ! pm2 list | grep -qE "ws|server"; then
    echo "   WebSocket process not found, attempting to start..."
    cd ~/worldguesser
    pm2 start npm --name "ws" -- run start-ws 2>/dev/null || echo "   Could not start WebSocket process"
fi

# Reload Nginx
echo ""
echo "7. Reloading Nginx..."
sudo nginx -t && sudo systemctl reload nginx && echo "   ✅ Nginx reloaded successfully" || echo "   ❌ Nginx reload failed"

echo ""
echo "=== Diagnostic Complete ==="
echo ""
echo "If still not working, check:"
echo "  - PM2 logs: pm2 logs ws"
echo "  - Nginx logs: sudo tail -f /var/log/nginx/error.log"
echo "  - WebSocket server port: grep WS_PORT ~/worldguesser/.env.local"
echo ""
echo "To manually restart everything:"
echo "  cd ~/worldguesser"
echo "  pm2 restart all"
echo "  sudo systemctl reload nginx"

