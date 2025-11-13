#!/bin/bash
# Script to verify that all recent changes are properly deployed

echo "🔍 Verifying Proguessr Deployment..."
echo ""

# Navigate to project directory
cd ~/worldguesser || cd /root/worldguesser

# Check 1: Git status
echo "📥 Checking Git status..."
git status
echo ""

# Check 2: Latest commit
echo "📝 Latest commit:"
git log -1 --oneline
echo ""

# Check 3: Environment variables
echo "🔑 Checking environment variables..."
if grep -q "NEXT_PUBLIC_GOOGLE_MAPS_API_KEY" .env 2>/dev/null; then
    echo "✅ NEXT_PUBLIC_GOOGLE_MAPS_API_KEY is set in .env"
    grep "NEXT_PUBLIC_GOOGLE_MAPS_API_KEY" .env | head -1
else
    echo "⚠️  NEXT_PUBLIC_GOOGLE_MAPS_API_KEY not found in .env"
    echo "   Add it with: echo 'NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=your_key' >> .env"
fi
echo ""

# Check 4: Build output exists
echo "📦 Checking build output..."
if [ -d "out" ]; then
    echo "✅ Build output directory exists"
    if [ -f "out/index.html" ]; then
        echo "✅ index.html exists"
        BUILD_TIME=$(stat -c %y out/index.html 2>/dev/null || stat -f "%Sm" out/index.html 2>/dev/null)
        echo "   Last built: $BUILD_TIME"
    else
        echo "⚠️  index.html not found - may need to rebuild"
    fi
else
    echo "❌ Build output directory not found - need to run: npm run build"
fi
echo ""

# Check 5: PM2 services
echo "🔄 Checking PM2 services..."
pm2 status
echo ""

# Check 6: Check if API key is in built files
echo "🔍 Checking if API key changes are in built files..."
if grep -r "NEXT_PUBLIC_GOOGLE_MAPS_API_KEY" out/_next/static 2>/dev/null | head -1 > /dev/null; then
    echo "✅ Environment variable is referenced in build"
else
    echo "⚠️  Environment variable not found in build - may need to rebuild"
fi
echo ""

# Check 7: Nginx status
echo "🌐 Checking Nginx status..."
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx is running"
else
    echo "❌ Nginx is not running"
fi
echo ""

# Check 8: Recent PM2 logs
echo "📋 Recent PM2 logs (last 5 lines):"
pm2 logs --lines 5 --nostream 2>/dev/null || echo "Could not fetch logs"
echo ""

echo "✅ Verification complete!"
echo ""
echo "🌐 To test in browser:"
echo "   1. Open your site: https://proguessr.com"
echo "   2. Open browser DevTools (F12)"
echo "   3. Go to Console tab"
echo "   4. Look for any Google Maps errors"
echo "   5. Test custom maps in incognito mode"
echo ""
echo "💡 If you see errors, check:"
echo "   - Browser console for specific error messages"
echo "   - Google Cloud Console API key restrictions"
echo "   - PM2 logs: pm2 logs"

