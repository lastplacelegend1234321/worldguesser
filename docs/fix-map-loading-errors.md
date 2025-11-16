# Fix: Map Loading Errors on Different Computers/Incognito

## Problem
When accessing the site on a different computer or in incognito mode:
- "Error loading map" popup appears
- Perpetual loading screen with no map ever loading

## Root Causes

1. **API URL Not Configured**: `NEXT_PUBLIC_API_URL` environment variable not set, causing fallback to `localhost:3001`
2. **API Endpoint Not Accessible**: `/allCountries.json` endpoint not accessible from external devices
3. **No Timeout Handling**: Fetch requests hang indefinitely if API is unreachable
4. **Poor Error Handling**: Fallback method doesn't properly handle errors or stop loading state

## Solution

### 1. Auto-Detect API URL
Updated `clientConfig.js` to automatically use the current hostname if `NEXT_PUBLIC_API_URL` is not set:
- In production: Uses `window.location.hostname` (e.g., `proguessr.com`)
- In development: Falls back to `localhost:3001`

### 2. Improved Error Handling
- Added timeout (10 seconds) to prevent hanging requests
- Better error detection (checks for localhost in production)
- Properly stops loading state in all error cases
- Better console logging for debugging

### 3. Enhanced Fallback Method
- Properly handles errors in client-side location generation
- Always stops loading state
- Shows appropriate error messages

## Code Changes

### `clientConfig.js`
- Auto-detects API URL from current hostname if env var not set
- Prevents localhost URLs in production

### `components/home.js`
- Added timeout handling for fetch requests
- Improved error detection and handling
- Better fallback method with proper error handling
- Always stops loading state

## Verification Steps

1. **Check Environment Variables** (on server):
   ```bash
   cd ~/worldguesser
   cat .env.local | grep NEXT_PUBLIC_API_URL
   ```
   
   Should show: `NEXT_PUBLIC_API_URL=proguessr.com` (or your domain)

2. **Test API Endpoint**:
   ```bash
   curl https://proguessr.com/allCountries.json
   ```
   
   Should return JSON with `ready: true` and locations array

3. **Check Nginx Configuration**:
   Ensure `/allCountries.json` is proxied to API server:
   ```nginx
   location /allCountries.json {
       proxy_pass http://api_backend;
       # ... other proxy settings
   }
   ```

4. **Test in Browser**:
   - Open browser console
   - Look for "Fetching locations from: https://proguessr.com/allCountries.json"
   - Should see successful response or fallback message

## If Still Not Working

1. **Check API Server is Running**:
   ```bash
   pm2 status
   # Should show worldguessr-api running
   ```

2. **Check API Server Logs**:
   ```bash
   pm2 logs worldguessr-api --lines 50
   ```

3. **Verify Nginx Proxy**:
   ```bash
   sudo nginx -t
   sudo systemctl reload nginx
   ```

4. **Test Direct API Access**:
   ```bash
   curl http://localhost:8001/allCountries.json
   ```
   
   Should work from server. If not, API server issue.

5. **Check CORS Headers**:
   API server should send CORS headers. Check `serverUtils/setCorsHeaders.js`

## Expected Behavior After Fix

- ✅ API URL auto-detected from current domain
- ✅ 10-second timeout prevents infinite loading
- ✅ Proper error messages shown
- ✅ Fallback to client-side generation if API fails
- ✅ Loading state always stops (no perpetual loading)

