# Fix Multiplayer Connection Issues

## Problem
Multiplayer shows "connection lost" error when trying to connect.

## Root Causes

1. **Environment Variables Not Set**: The WebSocket URL depends on `NEXT_PUBLIC_WS_HOST` or `NEXT_PUBLIC_API_URL`
2. **WebSocket Server Not Running**: PM2 service might be down
3. **Nginx Proxy Misconfiguration**: WebSocket proxy might not be working correctly

## Solution Steps

### Step 1: Check Environment Variables

On your server, check if environment variables are set:

```bash
cd ~/worldguesser
cat .env.local
# OR
cat .env
```

You should see:
```bash
NEXT_PUBLIC_API_URL=proguessr.com
NEXT_PUBLIC_WS_HOST=proguessr.com
# OR if using separate domains:
# NEXT_PUBLIC_API_URL=api.proguessr.com
# NEXT_PUBLIC_WS_HOST=ws.proguessr.com
```

### Step 2: Verify WebSocket Server is Running

```bash
pm2 status
```

You should see `worldguessr-ws` running. If not:
```bash
pm2 start ecosystem.config.cjs
pm2 save
```

### Step 3: Check Nginx Configuration

Verify your Nginx config has the WebSocket proxy:

```bash
sudo nano /etc/nginx/sites-available/worldguessr
```

Make sure you have:
```nginx
location /wg {
    proxy_pass http://ws_backend;
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection $connection_upgrade;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header X-Forwarded-Proto $scheme;
}
```

Then reload Nginx:
```bash
sudo nginx -t  # Test config
sudo systemctl reload nginx
```

### Step 4: Check WebSocket Server Logs

```bash
pm2 logs worldguessr-ws --lines 50
```

Look for connection errors or startup issues.

### Step 5: Test WebSocket Connection

From your local machine, test the connection:
```bash
curl -i -N \
  -H "Connection: Upgrade" \
  -H "Upgrade: websocket" \
  -H "Sec-WebSocket-Version: 13" \
  -H "Sec-WebSocket-Key: test" \
  https://proguessr.com/wg
```

You should get a WebSocket handshake response (101 Switching Protocols).

### Step 6: Rebuild and Restart

If environment variables changed, rebuild:
```bash
cd ~/worldguesser
git pull
npm run build
pm2 restart all
```

## Common Issues

### Issue: "Connection lost" immediately
- **Cause**: WebSocket server not running or wrong port
- **Fix**: Check `pm2 status` and ensure `worldguessr-ws` is running on port 8002

### Issue: Connection works locally but not on production
- **Cause**: Environment variables not set in production
- **Fix**: Set `NEXT_PUBLIC_WS_HOST` in `.env.local` and rebuild

### Issue: Nginx 502 Bad Gateway
- **Cause**: WebSocket server not running or wrong upstream port
- **Fix**: Verify `ws_backend` in Nginx points to `localhost:8002` (or your WS_PORT)

## Quick Fix Script

Run this on your server:
```bash
#!/bin/bash
cd ~/worldguesser

# Check PM2
pm2 restart worldguessr-ws

# Check Nginx
sudo nginx -t && sudo systemctl reload nginx

# Check logs
pm2 logs worldguessr-ws --lines 20
```

