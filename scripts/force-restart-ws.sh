#!/bin/bash

echo "=== Force Restart WebSocket Server ==="
echo ""

echo "1. Stopping WebSocket server..."
pm2 stop worldguessr-ws
sleep 2

echo ""
echo "2. Deleting old process..."
pm2 delete worldguessr-ws
sleep 1

echo ""
echo "3. Checking ws.js syntax..."
cd ~/worldguesser
node --check ws/ws.js && echo "   ✅ Syntax OK" || {
    echo "   ❌ Syntax error detected!"
    exit 1
}

echo ""
echo "4. Starting WebSocket server..."
cd ~/worldguesser
pm2 start npm --name "worldguessr-ws" -- run start-ws

echo ""
echo "5. Waiting 3 seconds for startup..."
sleep 3

echo ""
echo "6. Checking status..."
pm2 list | grep worldguessr-ws

echo ""
echo "7. Checking latest logs..."
pm2 logs worldguessr-ws --lines 10 --nostream | tail -10

echo ""
echo "8. Checking if port 8002 is listening..."
if command -v ss &> /dev/null; then
    ss -tuln | grep ":8002" && echo "   ✅ Port 8002 is listening!" || echo "   ❌ Port 8002 is NOT listening"
elif command -v netstat &> /dev/null; then
    netstat -tuln | grep ":8002" && echo "   ✅ Port 8002 is listening!" || echo "   ❌ Port 8002 is NOT listening"
fi

echo ""
echo "=== Done ==="

