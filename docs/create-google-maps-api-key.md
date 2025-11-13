# How to Create and Set Up Google Maps API Key

## Step 1: Create Google Cloud Project

1. Go to: https://console.cloud.google.com/
2. Click **"Select a project"** (top bar)
3. Click **"New Project"**
4. Enter project name: `Proguessr` (or any name)
5. Click **"Create"**
6. Wait for project creation, then select it

## Step 2: Enable Billing

**IMPORTANT**: Google Maps requires billing, but you get $200/month free credit (usually enough for most sites).

1. Go to: **Billing** in the left menu
2. Click **"Link a billing account"**
3. Follow the prompts to add a payment method
4. Don't worry - you get $200/month free credit, and most small sites never exceed this

## Step 3: Enable Required APIs

1. Go to: **APIs & Services** > **Library**
2. Search for and enable these APIs (one by one):
   - **Maps JavaScript API** - Click "Enable"
   - **Street View Static API** - Click "Enable"
   - **Maps Embed API** - Click "Enable"
   - **Geocoding API** (optional, but recommended) - Click "Enable"

## Step 4: Create API Key

1. Go to: **APIs & Services** > **Credentials**
2. Click **"+ CREATE CREDENTIALS"** (top bar)
3. Select **"API key"**
4. A new API key will be created and displayed
5. **Copy the API key** - you'll need it!

## Step 5: Configure API Key Restrictions

**IMPORTANT**: Don't skip this step! It's crucial for security.

### A. Application Restrictions

1. Click **"Restrict key"** (or click on the key name to edit)
2. Under **"Application restrictions"**, select **"HTTP referrers (web sites)"**
3. Click **"ADD AN ITEM"** and add these (one per line):

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

4. Click **"Save"**

### B. API Restrictions

1. Under **"API restrictions"**, select **"Restrict key"**
2. Select these APIs:
   - ✅ Maps JavaScript API
   - ✅ Street View Static API
   - ✅ Maps Embed API
   - ✅ Geocoding API (if enabled)
3. Click **"Save"**

## Step 6: Add API Key to Your Server

On your DigitalOcean server:

```bash
cd ~/worldguesser
nano .env
```

Add this line (replace `YOUR_API_KEY_HERE` with your actual API key):

```bash
NEXT_PUBLIC_GOOGLE_MAPS_API_KEY=YOUR_API_KEY_HERE
```

Save and exit (`Ctrl+X`, then `Y`, then `Enter`)

## Step 7: Rebuild and Restart

```bash
cd ~/worldguesser
npm run build
pm2 restart all
```

## Step 8: Test

1. Open your site: `https://proguessr.com`
2. Try custom maps
3. Test in incognito mode
4. Check browser console (F12) for any errors

## Troubleshooting

### "API key not valid"
- Make sure you copied the entire API key
- Check for extra spaces in `.env` file
- Verify the API key in Google Cloud Console

### "RefererNotAllowedMapError"
- Check that your domain is in the HTTP referrer restrictions
- Make sure you included `*` wildcards
- Wait 5-15 minutes for changes to propagate

### "ApiNotActivatedMapError"
- Go to APIs & Services > Library
- Make sure all required APIs are enabled
- Wait a few minutes after enabling

### "Billing required"
- You need to enable billing (even for free tier)
- Google gives $200/month free credit
- Most small sites never exceed this

## Cost Information

- **Free tier**: $200/month credit
- **Maps JavaScript API**: $7 per 1,000 loads
- **Street View Static API**: $7 per 1,000 requests
- **Maps Embed API**: Free (unlimited)

**Example**: 10,000 map loads/month = $70, which is covered by the $200 free credit.

## Security Best Practices

1. ✅ **Always use HTTP referrer restrictions** (don't leave it open)
2. ✅ **Restrict to specific APIs** (don't allow all APIs)
3. ✅ **Monitor usage** in Google Cloud Console
4. ✅ **Set up usage quotas** to prevent abuse
5. ✅ **Rotate keys** if compromised

## Quick Checklist

- [ ] Google Cloud project created
- [ ] Billing enabled
- [ ] Required APIs enabled (Maps JavaScript, Street View Static, Maps Embed)
- [ ] API key created
- [ ] HTTP referrer restrictions configured
- [ ] API restrictions configured
- [ ] API key added to `.env` file
- [ ] Site rebuilt (`npm run build`)
- [ ] Services restarted (`pm2 restart all`)
- [ ] Tested in normal mode
- [ ] Tested in incognito mode

## Need Help?

If you're stuck:
1. Check browser console (F12) for specific error messages
2. Check Google Cloud Console for API usage and errors
3. Verify the API key is correct in `.env` file
4. Make sure all APIs are enabled

