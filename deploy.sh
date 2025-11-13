#!/bin/bash

# WorldGuessr Deployment Script
# Run this script to deploy updates to your DigitalOcean server

set -e  # Exit on error

echo "🚀 Starting deployment..."

# Navigate to project directory
cd "$(dirname "$0")"

# Pull latest changes
echo "📥 Pulling latest changes from Git..."
git pull origin master || git pull origin main

# Install/update dependencies
echo "📦 Installing dependencies..."
npm install

# Build Next.js application
echo "🔨 Building Next.js application..."
npm run build

# Restart PM2 processes
echo "🔄 Restarting PM2 processes..."
pm2 restart ecosystem.config.cjs || pm2 start ecosystem.config.cjs

# Show status
echo "✅ Deployment complete!"
echo ""
echo "📊 PM2 Status:"
pm2 status

echo ""
echo "📝 Recent logs:"
pm2 logs --lines 20 --nostream

