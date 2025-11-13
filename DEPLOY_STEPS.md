# 🚀 Deploy WorldGuessr - Your Droplet IP: 167.99.103.198

## Step 1: SSH Into Your Server

Open your terminal and run:

```bash
ssh root@167.99.103.198
```

If it asks for a password, enter the root password you set when creating the droplet.
If you used an SSH key, it should connect automatically.

## Step 2: Once You're Logged In, Run These Commands One by One

### 2.1 Update System
```bash
apt update && apt upgrade -y
```

### 2.2 Create User
```bash
adduser worldguessr
```
(It will ask for a password - create a strong password and remember it)
(You can press Enter for all the other questions)

```bash
usermod -aG sudo worldguessr
su - worldguessr
```

### 2.3 Install Node.js
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
node --version
npm --version
```

### 2.4 Install PM2
```bash
sudo npm install -g pm2
pm2 startup systemd
```
**IMPORTANT:** Copy the command it prints (looks like `sudo env PATH=...`) and run it!

### 2.5 Install Nginx
```bash
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
```

### 2.6 Install Redis
```bash
sudo apt install redis-server -y
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

### 2.7 Clone Repository
```bash
cd ~
git clone https://github.com/lastplacelegend1234321/worldguesser.git
cd worldguesser
npm install
```

This will take a few minutes...

### 2.8 Create .env File
```bash
nano .env
```

Paste this (you'll need to fill in your MongoDB and Google OAuth values):

```env
MONGODB=mongodb+srv://user:pass@cluster.mongodb.net/worldguessr
NEXT_PUBLIC_GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
API_PORT=3001
WS_PORT=8002
REDIS_URI=redis://localhost:6379
NEXT_PUBLIC_SITE_URL=http://167.99.103.198
```

**To save:**
- Press `Ctrl+X`
- Press `Y`
- Press `Enter`

### 2.9 Build the App
```bash
npm run build
```
(This will take a few minutes)

### 2.10 Start Services
```bash
pm2 start ecosystem.config.js
pm2 save
pm2 status
```

You should see 3 services: worldguessr-api, worldguessr-ws, worldguessr-cron

### 2.11 Configure Nginx
```bash
sudo nano /etc/nginx/sites-available/worldguessr
```

Delete everything, then paste this:

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
    server_name 167.99.103.198;

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

Then:
```bash
sudo ln -s /etc/nginx/sites-available/worldguessr /etc/nginx/sites-enabled/
sudo rm /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx
```

### 2.12 Configure Firewall
```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

## ✅ Done!

Your site should be live at: **http://167.99.103.198**

## Check Status

```bash
pm2 status
pm2 logs
```

