# Fix: Gray Areas on Google Maps Tiles

## Problem
Google Maps tiles show gray areas instead of loading completely. This happens because:

1. **Unauthorized Tile Access**: Google Maps tiles are being accessed without proper API key authentication
2. **Rate Limiting**: Google may block or rate-limit unauthorized tile requests
3. **Terms of Service**: Direct tile access violates Google's ToS - tiles should be accessed via official APIs

## Solution

### Option 1: Add API Key to Tile URLs (Quick Fix)
We've added the Google Maps API key to tile URLs. However, **Google Maps tile URLs don't officially support API keys**. This may not fully resolve the issue.

### Option 2: Use Google Maps JavaScript API Properly (Recommended)
The proper way is to use Google Maps JavaScript API with Leaflet integration:

1. **Install leaflet-google plugin**:
   ```bash
   npm install @react-leaflet/google-maps-loader
   ```

2. **Use Google Maps JavaScript API** instead of direct tile URLs

### Option 3: Switch to Alternative Tile Provider (Best for Compliance)
Use OpenStreetMap or other free tile providers that don't require API keys:

```javascript
// OpenStreetMap tiles (free, no API key needed)
url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"

// Or CartoDB tiles
url="https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png"
```

## Current Implementation

We've added the API key to tile URLs in:
- `components/Map.js` - Main game map
- `components/roundOverScreen.js` - Round over screen maps

## Important Notes

⚠️ **Google Maps Terms of Service**: Using Google Maps tiles directly via Leaflet (without the official Google Maps JavaScript API) may violate Google's Terms of Service. For production use, consider:

1. Using Google Maps JavaScript API properly
2. Switching to OpenStreetMap or other free providers
3. Using Mapbox (requires API key but allows direct tile access)

## Testing

After deploying, check:
1. Do gray areas still appear?
2. Check browser console for tile loading errors
3. Verify API key restrictions allow your domain

## If Gray Areas Persist

1. **Check API Key Restrictions**:
   - Ensure `proguessr.com/*` is allowed in Google Cloud Console
   - Verify Maps JavaScript API is enabled

2. **Check Browser Console**:
   - Look for 403/429 errors on tile requests
   - Check for CORS errors

3. **Consider Alternative Providers**:
   - OpenStreetMap (free, no restrictions)
   - Mapbox (requires API key but allows direct tiles)
   - CartoDB (free tier available)

## Next Steps

If gray areas persist after adding API key:
1. Switch to OpenStreetMap tiles (recommended for compliance)
2. Or implement proper Google Maps JavaScript API integration
3. Or use Mapbox tiles with proper API key setup

