# How to Verify Changes Are Implemented

## Quick Verification Steps

### 1. **Check Server Status (SSH into your server)**

Run this on your DigitalOcean server:

```bash
cd ~/worldguesser
bash verify-deployment.sh
```

Or manually check:

```bash
# Check latest commit
git log -1 --oneline

# Check if environment variable is set
grep NEXT_PUBLIC_GOOGLE_MAPS_API_KEY .env

# Check if build exists
ls -la out/index.html

# Check PM2 services
pm2 status
```

### 2. **Check in Browser (Normal Mode)**

1. Open your site: `https://proguessr.com`
2. Open **Developer Tools** (F12 or Right-click > Inspect)
3. Go to **Console** tab
4. Look for:
   - ✅ No Google Maps errors
   - ✅ Custom maps load correctly
   - ✅ Street View displays properly

### 3. **Check in Browser (Incognito Mode)**

1. Open **Incognito/Private window** (Ctrl+Shift+N or Cmd+Shift+N)
2. Navigate to: `https://proguessr.com`
3. Open **Developer Tools** (F12)
4. Go to **Console** tab
5. Try to use **Custom Maps**
6. Look for:
   - ✅ No "This page can't load Google Maps correctly" error
   - ✅ Maps load without errors
   - ✅ Street View displays properly

### 4. **Check Network Requests**

1. Open **Developer Tools** (F12)
2. Go to **Network** tab
3. Filter by "maps" or "google"
4. Look for requests to:
   - `maps.googleapis.com`
   - `google.com/maps/embed`
5. Check if requests return **200 OK** (not 403 Forbidden)

### 5. **Check Source Code**

In browser DevTools:
1. Go to **Sources** tab
2. Look for files like `_app.js` or `map.js`
3. Search for: `NEXT_PUBLIC_GOOGLE_MAPS_API_KEY`
4. Verify it's using the environment variable (not hardcoded)

### 6. **Check Environment Variable in Build**

On your server:

```bash
cd ~/worldguesser
# Check if variable is in .env
cat .env | grep GOOGLE_MAPS

# Check if it's in the build
grep -r "process.env.NEXT_PUBLIC_GOOGLE_MAPS_API_KEY" out/_next/static/ 2>/dev/null | head -1
```

## What to Look For

### ✅ Success Indicators:
- No Google Maps errors in console
- Custom maps load in both normal and incognito mode
- Street View displays correctly
- Network requests to Google Maps return 200 OK
- PM2 services are running
- Latest commit shows the changes

### ❌ Failure Indicators:
- "This page can't load Google Maps correctly" error
- 403 Forbidden errors in Network tab
- Maps don't load in incognito mode
- Console shows API key errors
- Build is older than your latest commit

## Common Issues

### Issue: Changes not showing
**Solution:**
```bash
cd ~/worldguesser
git pull
npm run build
pm2 restart all
```

### Issue: Environment variable not set
**Solution:**
```bash
cd ~/worldguesser
echo 'NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=AIzaSyA2fHNuyc768n9ZJLTrfbkWLNK3sLOK-iQ' >> .env
npm run build
pm2 restart all
```

### Issue: Still getting errors in incognito
**Solution:**
1. Check Google Cloud Console API key restrictions
2. Make sure HTTP referrer restrictions include your domain
3. Verify the API key is correct
4. Check browser console for specific error messages

## Quick Test Checklist

- [ ] Server has latest code (`git log` shows recent commits)
- [ ] Environment variable is set (check `.env` file)
- [ ] Build is recent (check `out/index.html` timestamp)
- [ ] PM2 services are running (`pm2 status`)
- [ ] No errors in normal mode browser console
- [ ] No errors in incognito mode browser console
- [ ] Custom maps work in normal mode
- [ ] Custom maps work in incognito mode
- [ ] Network requests return 200 OK

## Still Having Issues?

1. **Check PM2 logs:**
   ```bash
   pm2 logs
   ```

2. **Check Nginx logs:**
   ```bash
   sudo tail -f /var/log/nginx/error.log
   ```

3. **Check browser console** for specific error messages

4. **Verify Google Cloud Console** API key settings

5. **Test with a fresh incognito window** (close all incognito windows first)

