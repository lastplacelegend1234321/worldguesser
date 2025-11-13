# Google Maps Incognito Mode Fix

## Problem
Google Maps fails to load in incognito mode with error: "This page can't load Google Maps correctly"

## Root Cause
1. **Hardcoded API Key**: The Google Maps API key was hardcoded in multiple places
2. **Domain Restrictions**: The API key may have HTTP referrer restrictions that don't work properly in incognito mode
3. **No Environment Variable**: The API key wasn't configurable via environment variables

## Solution Applied

### 1. Made API Key Configurable
- Added `NEXT_PUBLIC_GOOGLE_MAPS_API_KEY` environment variable
- Updated all hardcoded API key instances to use the environment variable
- Added fallback to existing key for backward compatibility

### 2. Files Updated
- `components/findLatLong.js` - Google Maps Loader initialization
- `pages/map.js` - Street View embed URLs
- `components/streetview/streetView.js` - Street View iframe URLs

## Required Actions

### Step 1: Add Environment Variable
Add to your `.env` file on the server:

```bash
NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=AIzaSyA2fHNuyc768n9ZJLTrfbkWLNK3sLOK-iQ
```

Or use a new API key if you want to configure it properly.

### Step 2: Configure Google Cloud Console
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to **APIs & Services** > **Credentials**
3. Find your Google Maps API key
4. Click **Edit** on the API key

### Step 3: Fix API Key Restrictions
**IMPORTANT**: For incognito mode to work, you need to configure restrictions properly:

#### Option A: Remove HTTP Referrer Restrictions (Less Secure)
- Under "Application restrictions", select **None**
- This allows the API key to work from any domain, including incognito mode

#### Option B: Add Proper Domain Restrictions (Recommended)
- Under "Application restrictions", select **HTTP referrers (web sites)**
- Add these referrers:
  ```
  proguessr.com/*
  www.proguessr.com/*
  *.proguessr.com/*
  localhost:*
  127.0.0.1:*
  ```
- **Important**: Make sure to include `*` wildcards to allow subdomains and paths

#### Option C: Use IP Address Restrictions (For Testing)
- Under "Application restrictions", select **IP addresses (web servers, cron jobs, etc.)**
- Add your server's IP address: `167.99.103.198`
- Note: This won't work for client-side requests, only server-side

### Step 4: Enable Required APIs
Make sure these APIs are enabled in Google Cloud Console:
- ✅ Maps JavaScript API
- ✅ Street View Static API
- ✅ Maps Embed API

### Step 5: Rebuild and Deploy
```bash
cd ~/worldguesser
git pull
# Add NEXT_PUBLIC_GOOGLE_MAPS_API_KEY to .env file
npm run build
pm2 restart all
```

## Testing
1. Test in normal mode - should work as before
2. Test in incognito mode - should now work without errors
3. Test on different devices - should work consistently

## Troubleshooting

### Still Getting Errors in Incognito?
1. **Check API Key Restrictions**: Make sure HTTP referrer restrictions allow your domain
2. **Check API Quotas**: Make sure you haven't exceeded API quotas
3. **Check Browser Console**: Look for specific error messages
4. **Verify Environment Variable**: Make sure `NEXT_PUBLIC_GOOGLE_MAPS_API_KEY` is set correctly

### API Key Not Working?
1. Verify the API key is correct in Google Cloud Console
2. Check that the required APIs are enabled
3. Verify billing is enabled (Google Maps requires billing)
4. Check API quotas and limits

## Security Notes
- The API key is public (NEXT_PUBLIC_*), so it will be visible in the browser
- Use API key restrictions to limit usage
- Monitor API usage in Google Cloud Console
- Consider setting up usage quotas to prevent abuse

