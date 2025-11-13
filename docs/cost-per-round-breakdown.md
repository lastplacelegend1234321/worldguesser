# Cost Per Round Breakdown

## Your Game Structure
- **1 game = 5 rounds**
- **Each round = 1 Street View location**

## What Actually Costs Money

### ✅ FREE - Street View Display (Per Round)
**What users see:** Street View iframe  
**API:** Maps Embed API  
**Cost per round:** **$0** (FREE)  
**Total for 5 rounds:** **$0** ✅

### ⚠️ PAID - Location Generation (Per Game Session)

**Two scenarios:**

#### Scenario A: Single-Player Games
- Locations are **pre-fetched** from your server
- Server endpoints like `/allCountries.json` or `/mapLocations/${location}`
- **Cost: $0** (no Maps JavaScript API used)

#### Scenario B: Client-Side Generation (Fallback)
- Only used if server endpoints fail
- Uses `findLatLong.js` with Maps JavaScript API
- **Cost: $7 per 1,000 game sessions** (not per round)

## Actual Cost Per Round

### Street View Display:
- **Round 1:** $0 (FREE)
- **Round 2:** $0 (FREE)
- **Round 3:** $0 (FREE)
- **Round 4:** $0 (FREE)
- **Round 5:** $0 (FREE)
- **Total for 5 rounds:** **$0** ✅

### Location Generation:
- **Per game (5 rounds):** $0.007 (less than 1 cent)
- **Per round:** $0.0014 (essentially $0)
- **Only if using client-side generation** (most games use server endpoints = $0)

## Real-World Example

**1 user plays 1 game (5 rounds):**

**Street View (what they see):**
- 5 rounds × $0 = **$0** ✅

**Location generation:**
- Most likely: Uses server endpoints = **$0** ✅
- Fallback: Uses client-side = $0.007 (less than 1 cent)

**Total cost: $0 - $0.007**

## Why This Is So Low

1. **Street View uses Embed API** = FREE (unlimited)
2. **Locations are pre-generated** on your server (no API cost)
3. **Maps JavaScript API** only loads once per game session (not per round)
4. **Server-side generation** doesn't use Maps JavaScript API

## Cost Breakdown for Different Scenarios

### 1,000 users play 1 game each (5 rounds):

**Street View:** 5,000 rounds × $0 = **$0** ✅

**Location generation:**
- If all use server endpoints: **$0** ✅
- If all use client-side: 1,000 sessions × $0.007 = **$7**

**Total: $0 - $7**

### 1,000 users play 10 games each (50 rounds total):

**Street View:** 50,000 rounds × $0 = **$0** ✅

**Location generation:**
- If all use server endpoints: **$0** ✅
- If all use client-side: 1,000 users × 10 games × $0.007 = **$70**

**Total: $0 - $70**

## The Key Point

**Each round showing Street View = $0** (FREE)

**Location generation = $0.007 per game** (not per round)

**So:**
- 1 game (5 rounds) = $0 - $0.007
- 1 round = $0 (Street View) + $0.0014 (location generation, if needed)

## Bottom Line

- **Street View per round: $0** ✅
- **Location generation per round: ~$0** (essentially free)
- **You're paying for game sessions, not rounds**
- **Most games use free server endpoints anyway**

You're in good shape! The $200/month free credit will cover a LOT of games.

