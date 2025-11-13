# Why Google Maps Works Locally But Not Globally

## The Issue

Your Google Maps API key works on `localhost` but fails on `proguessr.com` and in incognito mode. Here's why:

## Most Likely Cause: HTTP Referrer Restrictions

The API key in Google Cloud Console likely has **HTTP referrer restrictions** that only allow `localhost`, but not your production domain.

### How It Works:

1. **When you test locally:**
   - Your site runs on: `http://localhost:3000` or `http://127.0.0.1:3000`
   - Google Maps API checks the referrer (where the request came from)
   - If the API key allows `localhost:*` → ✅ **Works**

2. **When someone visits your production site:**
   - Your site runs on: `https://proguessr.com`
   - Google Maps API checks the referrer
   - If the API key only allows `localhost` → ❌ **Blocked**

3. **In incognito mode:**
   - Referrer headers can be different or stricter
   - Even if `proguessr.com` is allowed, incognito might send different referrer info
   - If restrictions are too strict → ❌ **Blocked**

## How to Check Your Current Restrictions

1. Go to: https://console.cloud.google.com/
2. Navigate to: **APIs & Services** > **Credentials**
3. Find your API key: `AIzaSyA2fHNuyc768n9ZJLTrfbkWLNK3sLOK-iQ`
4. Click on it to see current restrictions

### What You'll Probably See:

**Application restrictions:**
- Currently set to: `localhost:*` or `127.0.0.1:*`
- This is why it works locally but not globally

## The Fix

### Step 1: Edit the API Key

1. Click **"Edit"** on your API key
2. Under **"Application restrictions"**, you'll see current allowed referrers

### Step 2: Add Your Production Domain

Add these referrers (one per line):

```
localhost:*
127.0.0.1:*
proguessr.com/*
www.proguessr.com/*
*.proguessr.com/*
http://proguessr.com/*
https://proguessr.com/*
http://www.proguessr.com/*
https://www.proguessr.com/*
```

### Step 3: Save and Wait

- Click **"Save"**
- Wait **5-15 minutes** for changes to propagate
- Test on production site

## Other Possible Causes

### 1. IP Address Restrictions
If the API key is restricted to specific IP addresses:
- Your local IP might be allowed
- Production server IP might not be
- External user IPs definitely won't be

**Fix:** Change to "HTTP referrers" instead of "IP addresses"

### 2. API Restrictions
If certain APIs aren't enabled:
- Might work for some features locally
- Fail for others globally

**Fix:** Enable all required APIs (Maps JavaScript, Street View Static, Maps Embed)

### 3. Browser Caching
Your local browser might have cached the maps:
- Appears to work locally
- But new requests actually fail

**Fix:** Clear browser cache and test again

## Quick Test

To verify this is the issue:

1. **Temporarily remove all restrictions:**
   - Set "Application restrictions" to **"None"**
   - Save and wait 5 minutes
   - Test on production site
   - If it works → restrictions were the problem
   - **Then add proper restrictions back** (don't leave it open!)

2. **Check browser console:**
   - Open DevTools (F12) on production site
   - Look for error: `RefererNotAllowedMapError`
   - This confirms referrer restrictions are the issue

## Summary

- **Local works** = API key allows `localhost`
- **Global fails** = API key doesn't allow `proguessr.com`
- **Incognito fails** = Referrer restrictions too strict for incognito mode
- **Fix** = Add your production domain to allowed referrers

The solution is to add `proguessr.com` to the HTTP referrer restrictions in Google Cloud Console.

