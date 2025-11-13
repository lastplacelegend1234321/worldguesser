#!/bin/bash

# WorldGuessr Server Deployment Script
# Run this on your DigitalOcean droplet after SSH'ing in

set -e  # Exit on error

echo "🚀 Starting WorldGuessr deployment..."
echo ""

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    echo "⚠️  Running as root. Creating user and switching..."
    apt update && apt upgrade -y
    
    # Create user if it doesn't exist
    if ! id "worldguessr" &>/dev/null; then
        echo "Creating user 'worldguessr'..."
        adduser --disabled-password --gecos "" worldguessr
        usermod -aG sudo worldguessr
        echo "worldguessr ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers
    fi
    
    # Switch to worldguessr user and re-run script
    echo "Switching to worldguessr user..."
    sudo -u worldguessr bash << 'EOF'
cd ~
if [ ! -f ~/deploy-server.sh ]; then
    echo "Please download deploy-server.sh to the server first"
    exit 1
fi
bash ~/deploy-server.sh
EOF
    exit 0
fi

# Now running as worldguessr user
echo "✅ Running as user: $(whoami)"
echo ""

# Step 1: Update system
echo "📦 Step 1: Updating system..."
sudo apt update && sudo apt upgrade -y

# Step 2: Install Node.js
echo ""
echo "📦 Step 2: Installing Node.js..."
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
else
    echo "Node.js already installed: $(node --version)"
fi

# Step 3: Install PM2
echo ""
echo "📦 Step 3: Installing PM2..."
if ! command -v pm2 &> /dev/null; then
    sudo npm install -g pm2
    pm2 startup systemd | grep "sudo env" | bash || true
else
    echo "PM2 already installed"
fi

# Step 4: Install Nginx
echo ""
echo "📦 Step 4: Installing Nginx..."
if ! command -v nginx &> /dev/null; then
    sudo apt install nginx -y
    sudo systemctl enable nginx
    sudo systemctl start nginx
else
    echo "Nginx already installed"
fi

# Step 5: Install Redis
echo ""
echo "📦 Step 5: Installing Redis..."
if ! command -v redis-server &> /dev/null; then
    sudo apt install redis-server -y
    sudo systemctl enable redis-server
    sudo systemctl start redis-server
else
    echo "Redis already installed"
fi

# Step 6: Clone/Update repository
echo ""
echo "📦 Step 6: Setting up repository..."
if [ -d ~/worldguesser ]; then
    echo "Repository exists, pulling latest changes..."
    cd ~/worldguesser
    git pull origin master || git pull origin main
else
    echo "Cloning repository..."
    cd ~
    git clone https://github.com/lastplacelegend1234321/worldguesser.git
    cd worldguesser
fi

# Step 7: Install dependencies
echo ""
echo "📦 Step 7: Installing dependencies..."
npm install

# Step 8: Create .env file if it doesn't exist
echo ""
echo "📦 Step 8: Setting up .env file..."
if [ ! -f .env ]; then
    echo "Creating .env file with default values..."
    cat > .env << 'ENVEOF'
MONGODB=mongodb+srv://user:pass@cluster.mongodb.net/worldguessr
NEXT_PUBLIC_GOOGLE_CLIENT_ID=your_google_client_id
GOOGLE_CLIENT_SECRET=your_google_client_secret
API_PORT=3001
WS_PORT=8002
REDIS_URI=redis://localhost:6379
NEXT_PUBLIC_SITE_URL=http://167.99.103.198
ENVEOF
    echo "✅ .env file created with template values"
    echo "⚠️  IMPORTANT: Edit .env file with your actual MongoDB and Google OAuth credentials"
    echo "   You can do this now with: nano .env"
    echo "   Or edit it later and restart services with: pm2 restart all"
    echo ""
    read -p "Press Enter to continue (you can edit .env later if needed)..."
else
    echo "✅ .env file already exists"
fi

# Step 9: Build the app
echo ""
echo "📦 Step 9: Building Next.js application..."
npm run build

# Step 10: Configure Nginx
echo ""
echo "📦 Step 10: Configuring Nginx..."
sudo tee /etc/nginx/sites-available/worldguessr > /dev/null << 'NGINXEOF'
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
NGINXEOF

# Enable site
sudo ln -sf /etc/nginx/sites-available/worldguessr /etc/nginx/sites-enabled/
sudo rm -f /etc/nginx/sites-enabled/default
sudo nginx -t
sudo systemctl reload nginx

# Step 11: Configure firewall
echo ""
echo "📦 Step 11: Configuring firewall..."
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# Step 12: Start PM2 services
echo ""
echo "📦 Step 12: Starting services with PM2..."
cd ~/worldguesser
pm2 delete all 2>/dev/null || true
pm2 start ecosystem.config.js
pm2 save

echo ""
echo "✅ Deployment complete!"
echo ""
echo "📊 PM2 Status:"
pm2 status
echo ""
echo "🌐 Your site should be live at: http://167.99.103.198"
echo ""
echo "📝 Useful commands:"
echo "   pm2 logs          - View logs"
echo "   pm2 restart all   - Restart services"
echo "   pm2 status       - Check status"

