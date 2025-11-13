# When Google Maps API Costs Money

## Always FREE ✅

### 1. Street View Display (What Users See)
- **API:** Maps Embed API
- **Cost:** **FREE** (unlimited)
- **When:** Every time a user sees Street View
- **Your usage:** Every round of every game
- **Cost:** **$0** ✅

## When You PAY 💰

### 1. Maps JavaScript API Loads

**Cost:** $7 per 1,000 loads

**When this happens:**
- When `findLatLong.js` is used client-side
- This only happens as a **fallback** when server endpoints fail
- The `Loader` loads the Maps JavaScript API library

**Current code flow:**
1. First tries: Server endpoints (`/allCountries.json`, `/mapLocations/${location}`) = **FREE**
2. Fallback: `findLatLongRandom()` client-side = **$7 per 1,000 loads**

**So you pay when:**
- Server endpoints are down/unavailable
- User is offline
- Server fails to respond
- Using client-side location generation as fallback

### 2. Street View Static API (If You Used It)

**Cost:** $7 per 1,000 requests

**When this would happen:**
- If you switched from Embed API to Static API
- Currently you use Embed API = **FREE**
- So this doesn't apply to you

## Real-World Scenarios

### Scenario 1: Normal Operation (99% of the time)
- Locations from server endpoints = **FREE** ✅
- Street View embeds = **FREE** ✅
- **Total cost: $0**

### Scenario 2: Server Down (Rare)
- Server endpoints fail
- Falls back to client-side `findLatLongRandom()`
- Maps JavaScript API loads = **$7 per 1,000 loads**
- **Cost: $0.007 per game session**

### Scenario 3: High Traffic + Server Issues
- 10,000 users hit server issues
- All fall back to client-side generation
- 10,000 Maps JavaScript API loads = **$70**
- **But this is rare** - server should handle most requests

## When You'd Actually Pay

### You pay if:
1. ✅ **Server endpoints fail** and fallback is used
2. ✅ **High volume** of fallback usage (unlikely)
3. ✅ **You exceed $200/month free credit**

### You DON'T pay for:
- ❌ Street View displays (Embed API = FREE)
- ❌ Server-side location generation (no API used)
- ❌ Pre-generated location files (no API used)
- ❌ Normal game operation (uses server endpoints)

## Cost Calculation

### Normal Operation:
- **Cost: $0** ✅
- Uses server endpoints (free)
- Street View embeds (free)

### If Fallback Used:
- **1,000 game sessions** using fallback = **$7**
- **10,000 game sessions** using fallback = **$70**
- **100,000 game sessions** using fallback = **$700**

### With $200 Free Credit:
- First **~28,500 game sessions** using fallback = **FREE**
- After that = **$7 per 1,000 sessions**

## How to Minimize Costs

### 1. Keep Server Endpoints Working
- Ensure `/allCountries.json` is available
- Ensure `/mapLocations/${location}` endpoints work
- Monitor server health

### 2. Pre-generate Locations
- Your server already does this (cron.js)
- More pre-generated = less fallback usage
- **Cost: $0**

### 3. Monitor Usage
- Check Google Cloud Console regularly
- Set up usage alerts
- Set daily quotas to prevent surprises

### 4. Consider Removing Client-Side Fallback
- If server is reliable, remove `findLatLongRandom` fallback
- Force server-only location generation
- **Cost: $0** (but less resilient)

## Bottom Line

**You pay when:**
- Server endpoints fail (rare)
- Fallback to client-side generation is used
- You exceed $200/month free credit

**You DON'T pay for:**
- Normal operation (99% of the time)
- Street View displays (always free)
- Server-side location generation (always free)

**Realistic cost:**
- **Most months: $0** (server handles everything)
- **Bad months: $0-50** (if server has issues)
- **Very bad months: $50-200** (if server is down a lot)

The $200/month free credit should cover you in almost all scenarios unless your server is frequently down.

