#!/bin/bash
# Multiplayer Fix Script - Run this on your server

set -e  # Exit on error

echo "🔧 Fixing Multiplayer Connection..."
echo ""

cd ~/worldguesser

# Step 1: Check environment variables
echo "1️⃣ Checking environment variables..."
if [ -f .env.local ]; then
    echo "Found .env.local:"
    grep -E "NEXT_PUBLIC_WS_HOST|NEXT_PUBLIC_API_URL|WS_PORT" .env.local || echo "⚠️  No WebSocket env vars found"
else
    echo "⚠️  .env.local not found - creating it..."
    touch .env.local
fi
echo ""

# Step 2: Set environment variables if missing
echo "2️⃣ Setting environment variables..."
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
echo ""

# Step 3: Check PM2 services
echo "3️⃣ Checking PM2 services..."
pm2 status
echo ""

# Step 4: Restart WebSocket server
echo "4️⃣ Restarting WebSocket server..."
pm2 restart worldguessr-ws || pm2 start ecosystem.config.cjs --only worldguessr-ws
pm2 save
echo ""

# Step 5: Check Nginx configuration
echo "5️⃣ Checking Nginx configuration..."
if sudo nginx -t 2>&1 | grep -q "successful"; then
    echo "✅ Nginx configuration is valid"
    sudo systemctl reload nginx
    echo "✅ Nginx reloaded"
else
    echo "❌ Nginx configuration has errors:"
    sudo nginx -t
fi
echo ""

# Step 6: Rebuild frontend with new env vars
echo "6️⃣ Rebuilding frontend..."
npm run build
echo ""

# Step 7: Restart all services
echo "7️⃣ Restarting all services..."
pm2 restart all
echo ""

# Step 8: Check logs
echo "8️⃣ Checking WebSocket logs (last 20 lines)..."
pm2 logs worldguessr-ws --lines 20 --nostream
echo ""

# Step 9: Test WebSocket endpoint
echo "9️⃣ Testing WebSocket endpoint..."
curl -I -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: test" \
  https://proguessr.com/wg 2>&1 | head -5
echo ""

echo "✅ Multiplayer fix complete!"
echo ""
echo "📋 Next steps:"
echo "   1. Visit https://proguessr.com"
echo "   2. Try connecting to multiplayer"
echo "   3. Check browser console for any errors"
echo "   4. If still having issues, run: pm2 logs worldguessr-ws"

