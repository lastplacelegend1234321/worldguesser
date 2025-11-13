# Fix Google Maps API Key Restrictions for Incognito & External Devices

## Problem
Custom maps work in normal mode on your device, but fail in:
- Incognito mode
- External devices (other locations/IPs)

## Root Cause
The Google Maps API key has **HTTP referrer restrictions** that are too strict or incorrectly configured.

## Solution: Fix API Key Restrictions

### Step 1: Access Google Cloud Console

1. Go to: https://console.cloud.google.com/
2. Select your project (or create one if needed)
3. Navigate to: **APIs & Services** > **Credentials**

### Step 2: Find Your API Key

Look for the key: `AIzaSyA2fHNuyc768n9ZJLTrfbkWLNK3sLOK-iQ`

Click on it to edit.

### Step 3: Configure Application Restrictions

**IMPORTANT**: For incognito and external devices to work, you need to configure this correctly.

#### Option A: Remove Restrictions (Easiest - Less Secure)

1. Under **"Application restrictions"**, select: **"None"**
2. Click **"Save"**
3. ⚠️ **Warning**: This allows the API key to be used from any domain. Monitor usage.

#### Option B: Configure HTTP Referrer Restrictions (Recommended)

1. Under **"Application restrictions"**, select: **"HTTP referrers (web sites)"**
2. Click **"ADD AN ITEM"** and add these referrers **one by one**:

```
proguessr.com/*
www.proguessr.com/*
*.proguessr.com/*
http://proguessr.com/*
https://proguessr.com/*
http://www.proguessr.com/*
https://www.proguessr.com/*
localhost:*
127.0.0.1:*
```

**Important Notes:**
- Use `*` wildcard to allow all paths and subdomains
- Include both `http://` and `https://` versions
- Include both with and without `www`
- Include `localhost` for local development

3. Click **"Save"**

### Step 4: Configure API Restrictions

1. Under **"API restrictions"**, select: **"Restrict key"**
2. Make sure these APIs are enabled:
   - ✅ Maps JavaScript API
   - ✅ Street View Static API
   - ✅ Maps Embed API
   - ✅ Geocoding API (if used)
3. Click **"Save"**

### Step 5: Wait for Propagation

API key changes can take **5-15 minutes** to propagate. Wait a bit, then test.

### Step 6: Test

1. **Normal mode**: Should still work
2. **Incognito mode**: Open incognito window, test custom maps
3. **External device**: Have someone else test from a different location

## Troubleshooting

### Still Not Working?

#### Check 1: Verify API Key is Correct
```bash
# On your server
cd ~/worldguesser
grep NEXT_PUBLIC_GOOGLE_MAPS_API_KEY .env
```

#### Check 2: Check Browser Console
1. Open DevTools (F12)
2. Go to **Console** tab
3. Look for specific error messages:
   - `RefererNotAllowedMapError` → Referrer restrictions are wrong
   - `ApiNotActivatedMapError` → API not enabled
   - `RefererNotAllowedMapError` → Domain not in allowed list

#### Check 3: Check Network Tab
1. Open DevTools (F12)
2. Go to **Network** tab
3. Filter by "maps" or "google"
4. Look for requests to `maps.googleapis.com`
5. Check the response:
   - **200 OK** = Working
   - **403 Forbidden** = API key restrictions issue
   - **400 Bad Request** = API key invalid or missing

#### Check 4: Verify APIs Are Enabled
1. Go to Google Cloud Console
2. Navigate to: **APIs & Services** > **Library**
3. Search for and enable:
   - Maps JavaScript API
   - Street View Static API
   - Maps Embed API

#### Check 5: Check Billing
Google Maps requires billing to be enabled (even for free tier):
1. Go to: **Billing** in Google Cloud Console
2. Make sure billing account is linked
3. Free tier gives $200/month credit (usually enough)

### Common Error Messages

#### "RefererNotAllowedMapError"
**Meaning**: Your domain is not in the allowed referrers list
**Fix**: Add your domain to HTTP referrer restrictions (see Step 3)

#### "ApiNotActivatedMapError"
**Meaning**: Required API is not enabled
**Fix**: Enable the required APIs (see Step 4)

#### "This page can't load Google Maps correctly"
**Meaning**: API key restrictions are blocking the request
**Fix**: Check referrer restrictions and API restrictions

## Alternative: Create a New API Key

If the current key is too restricted, create a new one:

1. Go to: **APIs & Services** > **Credentials**
2. Click **"Create Credentials"** > **"API Key"**
3. Configure it with proper restrictions (see above)
4. Update your `.env` file:
   ```bash
   NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=your_new_api_key_here
   ```
5. Rebuild:
   ```bash
   npm run build
   pm2 restart all
   ```

## Security Best Practices

1. **Use HTTP Referrer Restrictions** (not "None") for production
2. **Monitor API Usage** in Google Cloud Console
3. **Set Usage Quotas** to prevent abuse
4. **Rotate Keys** if compromised
5. **Use Different Keys** for development and production

## Quick Checklist

- [ ] API key restrictions set to "HTTP referrers" or "None"
- [ ] All domain variations added (with/without www, http/https)
- [ ] Required APIs enabled (Maps JavaScript, Street View Static, Maps Embed)
- [ ] Billing enabled in Google Cloud Console
- [ ] Environment variable set on server
- [ ] Site rebuilt after changes
- [ ] Waited 5-15 minutes for propagation
- [ ] Tested in incognito mode
- [ ] Tested on external device

## Still Having Issues?

1. **Check exact error in browser console** - this will tell you the specific problem
2. **Check Google Cloud Console** - look at API usage and errors
3. **Try removing all restrictions temporarily** - if it works, then restrictions are the issue
4. **Create a new API key** - start fresh with proper configuration

