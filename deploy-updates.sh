#!/bin/bash
# Script to deploy all recent changes (incognito fixes, mobile improvements, rebranding)

echo "🚀 Deploying Proguessr updates..."
echo ""

# Navigate to project directory
cd ~/worldguesser || cd /root/worldguesser

# Pull latest changes
echo "📥 Pulling latest changes from Git..."
git pull origin master || git pull origin main

# Install any new dependencies
echo ""
echo "📦 Installing dependencies..."
npm install

# Build the Next.js application
echo ""
echo "🔨 Building Next.js application..."
NODE_OPTIONS='--max-old-space-size=4096' npm run build

# Fix permissions for the out directory
echo ""
echo "🔧 Fixing file permissions..."
chmod -R 755 ~/worldguesser/out 2>/dev/null || chmod -R 755 /root/worldguesser/out
sudo chown -R www-data:www-data ~/worldguesser/out 2>/dev/null || sudo chown -R www-data:www-data /root/worldguesser/out

# Restart PM2 services
echo ""
echo "🔄 Restarting PM2 services..."
pm2 restart ecosystem.config.cjs || pm2 restart all

# Reload Nginx
echo ""
echo "🔄 Reloading Nginx..."
sudo systemctl reload nginx

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 PM2 Status:"
pm2 status
echo ""
echo "🌐 Your site should now be live with all updates:"
echo "   - Incognito mode fixes"
echo "   - Mobile improvements"
echo "   - Proguessr rebranding"
echo ""
echo "💡 If you see any issues, check logs with:"
echo "   pm2 logs"

