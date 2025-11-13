# Actual Google Maps API Costs for Your App

## What You're Actually Using

### ✅ FREE - Street View Embeds (What Users See)
**API:** Maps Embed API  
**Cost:** **FREE** (unlimited)  
**Where:** `components/streetview/streetView.js`, `pages/map.js`  
**Usage:** Every Street View iframe users see  
**Example:** User sees 200 rounds = **$0** ✅

### ⚠️ PAID - Maps JavaScript API (Location Generation)
**API:** Maps JavaScript API  
**Cost:** **$7 per 1,000 loads**  
**Where:** `components/findLatLong.js`  
**Usage:** Used to generate random locations (server-side or client-side)

## Important Clarification

### How Maps JavaScript API Billing Works:

**1 load = 1 time the API is initialized/loaded, NOT per function call**

- The `Loader` in `findLatLong.js` is created **once** when the module loads
- `importLibrary("streetView")` caches the library
- So it's **1 load per page session**, not per round

**Example:**
- User plays 200 rounds in one session
- Maps JavaScript API loads **once** when they start playing
- Cost: **1 request** (not 200)
- 1 request = $0.007 (less than 1 cent)

## Real Cost Calculation

### Scenario: 1,000 active users/day

**Street View Embeds (FREE):**
- Users see Street View: **FREE** ✅
- 1,000 users × 200 rounds = 200,000 views = **$0**

**Maps JavaScript API:**
- 1,000 users load the game page = **1,000 loads**
- 1,000 loads = **$7**
- Per month: 1,000 × 30 = 30,000 loads = **$210/month**

**BUT:** You get **$200/month free credit**
- $210 - $200 = **$10/month** actual cost

### Scenario: 10,000 active users/day

**Street View Embeds:** Still **FREE** ✅

**Maps JavaScript API:**
- 10,000 users/day × 30 days = 300,000 loads
- 300,000 ÷ 1,000 × $7 = **$2,100/month**
- Minus $200 credit = **$1,900/month**

## The Real Issue

If `findLatLong.js` is used **client-side** for each game, you might be loading the Maps JavaScript API multiple times. But looking at the code:

1. The `Loader` is created **once** at module load
2. `importLibrary` is cached
3. So it should be **1 load per page session**

However, if users refresh the page or start a new game session, that's a new load.

## How to Reduce Costs

### Option 1: Move Location Generation to Server
- Use `findLatLongServer.js` instead (doesn't use Maps JavaScript API)
- Generate locations on your server
- **Cost: $0** for location generation

### Option 2: Cache Locations
- Pre-generate locations
- Store in database
- Reuse for multiple users
- **Cost: Minimal** (only when generating new locations)

### Option 3: Use Static API for Location Generation
- Use Street View Static API instead of JavaScript API
- **Cost: $7 per 1,000** (same, but might be more efficient)

## Current Reality Check

**What you're actually paying for:**
- Street View users see: **FREE** ✅
- Location generation: **$7 per 1,000 game sessions** (not per round)

**So:**
- 1 user playing 200 rounds = **1 game session** = $0.007
- Not $1.40 as you calculated

**The key:** It's per **session/page load**, not per **round**.

## Recommendation

1. **Monitor your actual usage** in Google Cloud Console
2. **Set usage quotas** to prevent surprises
3. **Consider moving location generation to server** if costs get high
4. **Use the $200/month free credit** - most small/medium sites stay within this

## Bottom Line

- **Street View (what users see): FREE** ✅
- **Location generation: $7 per 1,000 game sessions** (not rounds)
- **1 user, 200 rounds = $0.007** (less than 1 cent)
- **You're likely fine** unless you have 10,000+ daily active users

