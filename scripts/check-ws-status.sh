#!/bin/bash

echo "=== WebSocket Server Status Check ==="
echo ""

echo "1. PM2 Status:"
pm2 list | grep worldguessr-ws

echo ""
echo "2. Most recent logs (last 5 lines):"
pm2 logs worldguessr-ws --lines 5 --nostream

echo ""
echo "3. Checking if port 8002 is listening:"
if command -v ss &> /dev/null; then
    ss -tuln | grep ":8002" && echo "   ✅ Port 8002 is listening" || echo "   ❌ Port 8002 is NOT listening"
elif command -v netstat &> /dev/null; then
    netstat -tuln | grep ":8002" && echo "   ✅ Port 8002 is listening" || echo "   ❌ Port 8002 is NOT listening"
fi

echo ""
echo "4. Testing WebSocket endpoint:"
curl -I --http1.1 --no-buffer -H "Connection: Upgrade" -H "Upgrade: websocket" -H "Sec-WebSocket-Key: test" -H "Sec-WebSocket-Version: 13" https://proguessr.com/wg 2>&1 | head -3

echo ""
echo "5. Checking for startup messages in logs:"
pm2 logs worldguessr-ws --lines 50 --nostream | grep -E "Starting|WS Server started|Database Connected|Connected to Redis" | tail -5

echo ""
echo "6. Checking for errors in last 10 lines:"
pm2 logs worldguessr-ws --lines 10 --nostream | tail -10

