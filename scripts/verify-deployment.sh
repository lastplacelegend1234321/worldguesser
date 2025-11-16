#!/bin/bash
# Deployment Verification Script

echo "🔍 Verifying Deployment..."
echo ""

echo "1️⃣ Checking PM2 Services..."
pm2 status
echo ""

echo "2️⃣ Checking Build Output..."
if [ -d ~/worldguesser/out ]; then
    echo "✅ Build output directory exists"
    FILE_COUNT=$(find ~/worldguesser/out -type f | wc -l)
    echo "   Files in out/: $FILE_COUNT"
    if [ -f ~/worldguesser/out/index.html ]; then
        echo "✅ index.html exists"
    else
        echo "❌ index.html missing!"
    fi
else
    echo "❌ Build output directory missing!"
fi
echo ""

echo "3️⃣ Checking Recent PM2 Logs (last 10 lines)..."
pm2 logs --lines 10 --nostream
echo ""

echo "4️⃣ Checking Git Status..."
cd ~/worldguesser
git log --oneline -1
echo ""

echo "5️⃣ Checking Nginx Status..."
if sudo systemctl is-active --quiet nginx; then
    echo "✅ Nginx is running"
else
    echo "❌ Nginx is not running!"
fi
echo ""

echo "6️⃣ Testing WebSocket Endpoint..."
curl -I -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: test" \
  https://proguessr.com/wg 2>&1 | head -3
echo ""

echo "✅ Verification complete!"
echo ""
echo "If everything looks good, test the site at: https://proguessr.com"

