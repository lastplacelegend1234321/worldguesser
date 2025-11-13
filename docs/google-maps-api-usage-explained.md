# Google Maps API Usage - What Counts as a Request

## Overview

Understanding what counts as a "request" helps you monitor usage and stay within the $200/month free credit.

## APIs You're Using

### 1. Maps JavaScript API
**Cost:** $7 per 1,000 loads

**What counts as a request:**
- ✅ Each time a map is **loaded/initialized** on a page
- ✅ Each time a user **visits a page** with a map
- ✅ Each time a map is **reloaded** (page refresh)
- ❌ **NOT** counted: Panning, zooming, clicking on the map
- ❌ **NOT** counted: Interacting with map controls

**Example:**
- User visits custom maps page → **1 request**
- User refreshes page → **1 more request**
- User navigates away and comes back → **1 more request**

**In your app:**
- Loading the custom maps page = 1 request per page load
- If you have multiple maps on one page, still = 1 request (one map instance)

### 2. Street View Static API
**Cost:** $7 per 1,000 requests

**What counts as a request:**
- ✅ Each time a Street View **image is loaded**
- ✅ Each time the Street View **iframe loads**
- ✅ Each time you **change location** in Street View
- ✅ Each time you **load a new panorama**

**Example:**
- User sees Street View → **1 request**
- User moves to next location → **1 more request**
- User refreshes page → **1 more request**

**In your app:**
- Each Street View iframe load = 1 request
- Changing locations in custom maps = 1 request per change
- Game rounds loading Street View = 1 request per round

### 3. Maps Embed API
**Cost:** **FREE** (unlimited)

**What counts as a request:**
- ✅ Nothing! This API is **completely free**
- ✅ Unlimited usage
- ✅ No charges

**In your app:**
- All Street View embeds using `maps/embed/v1/streetview` = **FREE**

## Your Current Usage Pattern

Based on your app:

### Custom Maps Page
- User visits `/map/slug` → **1 Maps JavaScript API request** (if using interactive map)
- Each Street View location shown → **1 Street View Static API request** (if using Static API)
- OR → **FREE** if using Maps Embed API (which you are!)

### Game Rounds
- Each round loads Street View → **1 Street View Static API request** (if using Static API)
- OR → **FREE** if using Maps Embed API

### Main Game
- Loading game UI with map → **1 Maps JavaScript API request** (if using interactive map)
- Street View for guessing → **1 Street View Static API request** per round
- OR → **FREE** if using Maps Embed API

## Cost Calculation Example

Let's say you have:
- **1,000 users/day** visiting custom maps
- Each user loads **5 Street View locations** on average
- Each user visits **2 pages** with maps

**Using Maps Embed API (FREE):**
- Custom maps: **FREE** (Embed API)
- Game rounds: **FREE** (Embed API)
- **Total cost: $0** ✅

**If using Static API instead:**
- 1,000 users × 5 locations = **5,000 requests/day**
- 5,000 × 30 days = **150,000 requests/month**
- 150,000 ÷ 1,000 × $7 = **$1,050/month**
- But you get **$200 free credit**
- **Cost: $850/month** ❌

## Good News for You

Looking at your code, you're using:
- **Maps Embed API** for Street View (`maps/embed/v1/streetview`)
- This is **FREE** and **unlimited**!

**So your costs are likely:**
- Maps JavaScript API: Only if you use interactive maps
- Street View: **FREE** (using Embed API)
- **Total: Very low, likely $0**

## How to Monitor Usage

1. Go to: https://console.cloud.google.com/
2. Navigate to: **APIs & Services** > **Dashboard**
3. Click on the API you want to check
4. View **"Requests"** chart
5. See daily/monthly usage

## Setting Usage Quotas (Recommended)

To prevent unexpected charges:

1. Go to: **APIs & Services** > **Dashboard**
2. Click on an API (e.g., Maps JavaScript API)
3. Click **"Quotas"** tab
4. Set daily limits (e.g., 10,000 requests/day)
5. Google will block requests after limit (prevents overage)

## Summary

**What counts:**
- ✅ Map loads (Maps JavaScript API) = $7 per 1,000
- ✅ Street View loads (Static API) = $7 per 1,000
- ✅ Street View embeds (Embed API) = **FREE**

**What doesn't count:**
- ❌ User interactions (pan, zoom, click)
- ❌ Map controls usage
- ❌ Just viewing a loaded map

**Your app:**
- Using Embed API = **Mostly FREE**
- Only pay for Maps JavaScript API if you use interactive maps
- **Likely cost: $0-50/month** (well within $200 free credit)

