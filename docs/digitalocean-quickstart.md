# DigitalOcean Quick Start Checklist

## Before You Start
- [ ] DigitalOcean account created
- [ ] Domain name ready (optional)
- [ ] MongoDB Atlas account OR plan to install MongoDB on VPS
- [ ] Google OAuth credentials ready

## Step-by-Step (Copy & Paste Commands)

### 1. Create Droplet
- Go to DigitalOcean → Create → Droplets
- Choose: Ubuntu 22.04, $12-24/month plan
- Add SSH key or use root password

### 2. Initial Setup (SSH into server)
```bash
ssh root@YOUR_DROPLET_IP

# Update system
apt update && apt upgrade -y

# Create user
adduser worldguessr
usermod -aG sudo worldguessr
su - worldguessr
```

### 3. Install Node.js & PM2
```bash
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
sudo npm install -g pm2
pm2 startup systemd
# Copy and run the command it prints
```

### 4. Install Nginx
```bash
sudo apt install nginx -y
sudo systemctl enable nginx
sudo systemctl start nginx
```

### 5. Install MongoDB Atlas (Recommended)
- Go to mongodb.com/cloud/atlas
- Create free cluster
- Get connection string
- Whitelist your droplet IP

### 6. Install Redis (Optional)
```bash
sudo apt install redis-server -y
sudo systemctl enable redis-server
sudo systemctl start redis-server
```

### 7. Clone & Setup Project
```bash
cd ~
git clone https://github.com/lastplacelegend1234321/worldguesser.git
cd worldguesser
npm install
npm run build
```

### 8. Create .env File
```bash
nano .env
```

Paste this (fill in your values):
```env
MONGODB=mongodb+srv://user:pass@cluster.mongodb.net/worldguessr
NEXT_PUBLIC_GOOGLE_CLIENT_ID=your_client_id
GOOGLE_CLIENT_SECRET=your_client_secret
API_PORT=3001
WS_PORT=8002
REDIS_URI=redis://localhost:6379
NEXT_PUBLIC_SITE_URL=https://yourdomain.com
```

Save: `Ctrl+X`, then `Y`, then `Enter`

### 9. Start Services with PM2
```bash
pm2 start ecosystem.config.js
pm2 save
pm2 status
```

### 10. Configure Nginx
```bash
sudo nano /etc/nginx/sites-available/worldguessr
```

Paste the config from `docs/digitalocean-deployment.md` (Step 11)

Then:
```bash
sudo ln -s /etc/nginx/sites-available/worldguessr /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### 11. Set Up SSL (If you have a domain)
```bash
sudo apt install certbot python3-certbot-nginx -y
sudo certbot --nginx -d yourdomain.com -d www.yourdomain.com
```

### 12. Configure Firewall
```bash
sudo ufw allow OpenSSH
sudo ufw allow 'Nginx Full'
sudo ufw enable
```

## Done! 🎉

Your site should now be live at:
- `http://YOUR_DROPLET_IP` (or your domain if configured)

## Quick Commands Reference

```bash
# View logs
pm2 logs

# Restart services
pm2 restart all

# Deploy updates
./deploy.sh

# Check Nginx status
sudo systemctl status nginx

# Check PM2 status
pm2 status
```

## Troubleshooting

**502 Bad Gateway?**
- Check if services are running: `pm2 status`
- Check logs: `pm2 logs`

**Can't connect to MongoDB?**
- Check MongoDB Atlas IP whitelist
- Verify connection string in `.env`

**WebSocket not working?**
- Check Nginx WebSocket config
- Verify WS_PORT in `.env` matches Nginx config

## Need Help?

See full guide: `docs/digitalocean-deployment.md`

