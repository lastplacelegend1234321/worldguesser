# 🚀 Deploy WorldGuessr to DigitalOcean - Step by Step

## Step 1: SSH into Your Droplet

Replace `YOUR_DROPLET_IP` with your actual IP from DigitalOcean:

```bash
ssh root@YOUR_DROPLET_IP
```

(Enter password when prompted, or use SSH key if you set one up)

## Step 2: Initial Server Setup

Once you're logged in, run these commands:

```bash
# Update system
apt update && apt upgrade -y

# Create a non-root user
adduser worldguessr
usermod -aG sudo worldguessr
su - worldguessr
```

## Step 3: Install Node.js & PM2

```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g pm2
pm2 startup systemd
# Copy and run the command it prints (it will look like: sudo env PATH=...)
```

## Step 4: Install Nginx

```bash
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
```

## Step 5: Install Redis

```bash
sudo apt install redis-server -y
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

## Step 6: Clone Your Repository

```bash
cd ~
git clone https://github.com/lastplacelegend1234321/worldguesser.git
cd worldguesser
npm install
npm run build
```

## Step 7: Create .env File

```bash
nano .env
```

Paste this template (replace with your actual values):

```env
MONGODB=mongodb+srv://user:pass@cluster.mongodb.net/worldguessr
NEXT_PUBLIC_GOOGLE_CLIENT_ID=your_google_client_id_here
GOOGLE_CLIENT_SECRET=your_google_client_secret_here
API_PORT=3001
WS_PORT=8002
REDIS_URI=redis://localhost:6379
NEXT_PUBLIC_SITE_URL=http://YOUR_DROPLET_IP
```

**To save in nano:**
- Press `Ctrl+X`
- Press `Y`
- Press `Enter`

## Step 8: Start Services with PM2

```bash
pm2 start ecosystem.config.js
pm2 save
pm2 status
```

You should see 3 services running: `worldguessr-api`, `worldguessr-ws`, `worldguessr-cron`

## Step 9: Configure Nginx

```bash
sudo nano /etc/nginx/sites-available/worldguessr
```

Delete everything in the file, then paste this (replace `YOUR_DROPLET_IP` with your actual IP):

```nginx
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

upstream api_backend {
    server localhost:3001;
}

upstream ws_backend {
    server localhost:8002;
}

server {
    listen 80;
    server_name YOUR_DROPLET_IP;

    client_max_body_size 30M;

    root /home/worldguessr/worldguesser/out;
    index index.html;

    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/json application/javascript;

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

    location / {
        try_files $uri $uri.html $uri/ /index.html;
    }

    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    location ~* (sw\.js|workbox-.*\.js)$ {
        add_header Cache-Control "no-cache, no-store, must-revalidate";
        add_header Pragma "no-cache";
        expires 0;
    }
}
```

Save: `Ctrl+X`, then `Y`, then `Enter`

Then enable the site:

```bash
sudo ln -s /etc/nginx/sites-available/worldguessr /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

## Step 10: Configure Firewall

```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

## ✅ Done!

Your site should now be live at: `http://YOUR_DROPLET_IP`

## Check Everything is Working

```bash
# Check PM2 services
pm2 status

# Check logs
pm2 logs

# Check Nginx
sudo systemctl status nginx
```

## Troubleshooting

If you see a 502 error:
```bash
pm2 logs worldguessr-api
pm2 restart all
```

If MongoDB connection fails:
- Make sure your MongoDB Atlas IP whitelist includes your droplet IP (or 0.0.0.0/0 for all)

