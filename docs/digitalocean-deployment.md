# DigitalOcean Deployment Guide for WorldGuessr

## Prerequisites
- DigitalOcean account
- Domain name (optional but recommended)
- MongoDB Atlas account (recommended) OR MongoDB on the VPS

## Step 1: Create a DigitalOcean Droplet

1. Go to [DigitalOcean](https://www.digitalocean.com/)
2. Click **Create** → **Droplets**
3. Choose:
   - **Image**: Ubuntu 22.04 (LTS)
   - **Plan**: Basic, Regular Intel with SSD
     - **Minimum**: $12/month (2GB RAM, 1 vCPU) - for testing
     - **Recommended**: $24/month (4GB RAM, 2 vCPU) - for production
   - **Datacenter**: Choose closest to your users
   - **Authentication**: SSH keys (recommended) or root password
4. Click **Create Droplet**

## Step 2: Initial Server Setup

### Connect to your server:
```bash
ssh root@YOUR_DROPLET_IP
```

### Update system:
```bash
apt update && apt upgrade -y
```

### Create a non-root user:
```bash
adduser worldguessr
usermod -aG sudo worldguessr
su - worldguessr
```

## Step 3: Install Node.js and PM2

```bash
# Install Node.js 20.x
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version

# Install PM2 globally
sudo npm install -g pm2

# Install PM2 startup script
pm2 startup systemd
# Follow the instructions it prints
```

## Step 4: Install Nginx

```bash
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
```

## Step 5: Install MongoDB (OR use MongoDB Atlas)

### Option A: MongoDB Atlas (Recommended - Easier)
1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a free cluster
3. Create a database user
4. Whitelist your droplet IP (or 0.0.0.0/0 for all IPs)
5. Get your connection string (looks like: `mongodb+srv://user:pass@cluster.mongodb.net/worldguessr`)

### Option B: Install MongoDB on VPS
```bash
# Import MongoDB GPG key
wget -qO - https://www.mongodb.org/static/pgp/server-7.0.asc | sudo apt-key add -

# Add MongoDB repository
echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list

# Install MongoDB
sudo apt-get update
sudo apt-get install -y mongodb-org

# Start MongoDB
sudo systemctl start mongod
sudo systemctl enable mongod
```

## Step 6: Install Redis (Optional but Recommended)

```bash
sudo apt install redis-server -y
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

## Step 7: Clone Your Repository

```bash
cd ~
git clone https://github.com/lastplacelegend1234321/worldguesser.git
cd worldguesser
```

## Step 8: Install Dependencies and Build

```bash
npm install

# Build the Next.js app
npm run build
```

## Step 9: Set Up Environment Variables

Create `.env` file:
```bash
nano .env
```

Add these variables (replace with your actual values):
```env
# MongoDB
MONGODB=mongodb+srv://user:pass@cluster.mongodb.net/worldguessr
# OR if using local MongoDB:
# MONGODB=mongodb://localhost:27017/worldguessr

# Google OAuth
NEXT_PUBLIC_GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret

# Server Ports
API_PORT=3001
WS_PORT=8002

# Redis (if using)
REDIS_URI=redis://localhost:6379

# Site URL
NEXT_PUBLIC_SITE_URL=https://yourdomain.com

# Discord Webhook (optional)
DISCORD_WEBHOOK=https://discord.com/api/webhooks/...

# Other environment variables as needed
```

Save and exit (Ctrl+X, then Y, then Enter)

## Step 10: Configure PM2

Create `ecosystem.config.js` in the project root:
```bash
nano ecosystem.config.js
```

Add:
```javascript
module.exports = {
  apps: [
    {
      name: 'worldguessr-api',
      script: 'server.js',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        API_PORT: 3001,
      },
    },
    {
      name: 'worldguessr-ws',
      script: 'ws/ws.js',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
        WS_PORT: 8002,
        UWS_HTTP_MAX_HEADERS_SIZE: 16384,
      },
    },
    {
      name: 'worldguessr-cron',
      script: 'cron.js',
      instances: 1,
      exec_mode: 'fork',
      env: {
        NODE_ENV: 'production',
      },
    },
  ],
};
```

Start all services:
```bash
pm2 start ecosystem.config.js
pm2 save
```

Check status:
```bash
pm2 status
pm2 logs
```

## Step 11: Configure Nginx

Create Nginx config:
```bash
sudo nano /etc/nginx/sites-available/worldguessr
```

Add (replace `yourdomain.com` with your domain or use IP):
```nginx
# WebSocket upgrade map
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

# API server
upstream api_backend {
    server localhost:3001;
}

# WebSocket server
upstream ws_backend {
    server localhost:8002;
}

server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;

    # Increase body size for file uploads
    client_max_body_size 30M;

    # Serve static Next.js files
    root /home/worldguessr/worldguesser/out;
    index index.html;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;

    # API routes
    location /api/ {
        proxy_pass http://api_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }

    # WebSocket routes
    location /ws {
        proxy_pass http://ws_backend;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    # Static files and Next.js routes
    location / {
        try_files $uri $uri.html $uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Service worker and PWA files
    location ~* (sw\.js|workbox-.*\.js)$ {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        expires 0;
    }
}
```

Enable the site:
```bash
sudo ln -s /etc/nginx/sites-available/worldguessr /etc/nginx/sites-enabled/
sudo nginx -t  # Test configuration
sudo systemctl reload nginx
```

## Step 12: Set Up SSL with Let's Encrypt

```bash
# Install Certbot
sudo apt install certbot python3-certbot-nginx -y

# Get SSL certificate (replace with your domain)
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com

# Auto-renewal is set up automatically, but test it:
sudo certbot renew --dry-run
```

## Step 13: Configure Firewall

```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
sudo ufw status
```

## Step 14: Set Up Auto-Deployment (Optional)

### Option A: Manual Deployment Script
Create `deploy.sh`:
```bash
nano deploy.sh
```

Add:
```bash
#!/bin/bash
cd /home/worldguessr/worldguesser
git pull origin master
npm install
npm run build
pm2 restart all
```

Make executable:
```bash
chmod +x deploy.sh
```

### Option B: GitHub Actions (Advanced)
Set up CI/CD to automatically deploy on push.

## Step 15: Monitor and Maintain

### View logs:
```bash
pm2 logs
pm2 logs worldguessr-api
pm2 logs worldguessr-ws
pm2 logs worldguessr-cron
```

### Restart services:
```bash
pm2 restart all
```

### Update application:
```bash
cd ~/worldguesser
git pull
npm install
npm run build
pm2 restart all
```

### Check Nginx logs:
```bash
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log
```

## Troubleshooting

### If services won't start:
1. Check environment variables: `cat .env`
2. Check MongoDB connection
3. Check ports aren't in use: `sudo netstat -tulpn | grep LISTEN`
4. Check PM2 logs: `pm2 logs`

### If Nginx gives 502 errors:
1. Check if API/WS servers are running: `pm2 status`
2. Check Nginx error log: `sudo tail -f /var/log/nginx/error.log`
3. Verify ports in ecosystem.config.js match Nginx config

### If WebSocket connections fail:
1. Verify WebSocket proxy configuration in Nginx
2. Check firewall allows connections
3. Test WebSocket server directly: `curl http://localhost:8002`

## Cost Estimate

- **Droplet**: $12-24/month
- **MongoDB Atlas**: Free tier available (512MB)
- **Domain**: ~$10-15/year
- **Total**: ~$12-25/month

## Next Steps

1. Set up domain DNS to point to your droplet IP
2. Configure monitoring (optional)
3. Set up automated backups
4. Configure rate limiting if needed
5. Set up CDN for static assets (optional)

