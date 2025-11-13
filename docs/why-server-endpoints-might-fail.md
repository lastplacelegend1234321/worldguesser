# Why Server Endpoints Might Fail

## Your Server Endpoints

### 1. `/allCountries.json`
- **Served by:** API server (port 3001)
- **Source:** Cached data (`allCountriesCache`)
- **Updated by:** Cron service (port 3003) every 60 seconds

### 2. `/countryLocations/:country`
- **Served by:** API server (port 3001)
- **Source:** Cached data or fetches from cron service (port 3003)
- **Fallback:** Can use `findLatLongRandom` server-side

### 3. `/mapLocations/:slug`
- **Served by:** API server (port 3001)
- **Source:** MongoDB database
- **Requires:** Database connection

## When They Might Fail

### 1. API Server Down (Port 3001)
**Causes:**
- PM2 service crashed (`worldguessr-api`)
- Server ran out of memory
- Node.js process crashed
- Server rebooted and PM2 didn't auto-start

**Result:**
- All endpoints return 500/connection errors
- Client falls back to `findLatLongRandom()` = **Costs money**

**How to prevent:**
- Monitor PM2: `pm2 status`
- Set up auto-restart: `pm2 startup`
- Monitor server resources

### 2. Cron Service Down (Port 3003)
**Causes:**
- PM2 service crashed (`worldguessr-cron`)
- Cron service not running
- Port conflict

**Result:**
- `/allCountries.json` cache might be stale/empty
- `/countryLocations/:country` might fail
- Client falls back to `findLatLongRandom()` = **Costs money**

**How to prevent:**
- Ensure `worldguessr-cron` is running: `pm2 status`
- Check cron logs: `pm2 logs worldguessr-cron`

### 3. MongoDB Down/Unreachable
**Causes:**
- MongoDB Atlas connection lost
- Network issues
- Database credentials expired
- IP whitelist changed

**Result:**
- `/mapLocations/:slug` fails (404/500)
- Custom maps can't load
- Client might fall back = **Costs money**

**How to prevent:**
- Monitor MongoDB connection
- Check MongoDB Atlas dashboard
- Verify IP whitelist includes your server IP

### 4. Cache Empty on Startup
**Causes:**
- Server just started
- Cache hasn't been populated yet
- Cron service hasn't run yet

**Result:**
- `/allCountries.json` returns `ready: false`
- Client falls back to `findLatLongRandom()` = **Costs money**

**How to prevent:**
- Pre-populate cache on startup
- Wait for cache to fill before serving requests
- Use fallback gracefully

### 5. Network Issues
**Causes:**
- Server network problems
- DNS issues
- Firewall blocking internal requests
- `localhost:3003` not accessible

**Result:**
- API server can't fetch from cron service
- Cache doesn't update
- Endpoints might return stale/empty data

**How to prevent:**
- Monitor internal service communication
- Check firewall rules
- Verify localhost connectivity

### 6. High Load/Timeout
**Causes:**
- Too many concurrent requests
- Server overloaded
- Request timeout
- Memory pressure

**Result:**
- Endpoints timeout or return errors
- Client falls back = **Costs money**

**How to prevent:**
- Monitor server resources
- Scale up if needed
- Add request rate limiting
- Optimize database queries

### 7. Code Errors
**Causes:**
- Bug in endpoint handler
- Unhandled exception
- Invalid data format

**Result:**
- Endpoint crashes
- Returns 500 error
- Client falls back = **Costs money**

**How to prevent:**
- Proper error handling
- Logging and monitoring
- Testing before deployment

## Real-World Failure Scenarios

### Scenario 1: Server Reboot
1. Server reboots (maintenance/power outage)
2. PM2 services don't auto-start
3. Endpoints return connection errors
4. **Cost:** Users trigger fallback = **$7 per 1,000 games**

### Scenario 2: MongoDB Connection Lost
1. MongoDB Atlas IP whitelist changed
2. Database connection fails
3. `/mapLocations/:slug` returns 500 errors
4. **Cost:** Custom maps trigger fallback = **$7 per 1,000 games**

### Scenario 3: High Traffic
1. Server gets overloaded
2. Endpoints timeout
3. Cache can't update
4. **Cost:** Some users trigger fallback = **Variable cost**

## How to Monitor

### Check PM2 Status
```bash
pm2 status
# Should show all 3 services: api, ws, cron
```

### Check API Server
```bash
curl http://localhost:3001/allCountries.json
# Should return JSON with locations
```

### Check Cron Service
```bash
curl http://localhost:3003/allCountries.json
# Should return JSON with locations
```

### Check MongoDB
```bash
# Check server logs for MongoDB connection errors
pm2 logs worldguessr-api | grep -i mongo
```

## Prevention Checklist

- [ ] PM2 auto-start configured (`pm2 startup`)
- [ ] All services running (`pm2 status`)
- [ ] MongoDB connection stable
- [ ] Server has enough memory
- [ ] Cron service updating cache regularly
- [ ] Error handling in place
- [ ] Monitoring/alerts set up
- [ ] Regular health checks

## Bottom Line

**Server endpoints fail when:**
- Services crash/stop
- Database connection lost
- Server overloaded
- Network issues
- Code errors

**Most common causes:**
1. PM2 services not running
2. MongoDB connection issues
3. Server out of memory
4. Services not auto-starting after reboot

**To minimize costs:**
- Keep services running
- Monitor health
- Set up auto-restart
- Handle errors gracefully

The fallback is a safety net, but keeping your server healthy means it rarely gets used (and costs money).

