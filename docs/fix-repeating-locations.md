# Fix: Repeating Locations in Singleplayer Games

## Problem
When playing singleplayer games on different computers, users were seeing the same locations every time they played.

## Root Cause
For "all countries" mode, the code was:
1. Shuffling the locations array once
2. Always picking the first location (`data.locations[0]`)
3. Using sequential access (`locIndex + 1`) for subsequent rounds

This meant:
- The same first location appeared every game
- Locations were accessed in order, not randomly
- Different computers saw the same sequence because the shuffle happened the same way

## Solution
Changed the location selection to:
1. **Always pick a random location** from the available array
2. **Filter out the current location** to avoid immediate repeats
3. **Use `Math.random()`** for each selection instead of sequential access

## Code Changes

### Before:
```javascript
if (gameOptions.location === "all") {
    const loc = data.locations[0]  // Always first location
    setLatLong(loc)
}
```

### After:
```javascript
if (gameOptions.location === "all") {
    // Pick a random location instead of always using the first one
    const loc = data.locations[Math.floor(Math.random() * data.locations.length)]
    setLatLong(loc)
}
```

### Before (next round):
```javascript
if (gameOptions.location === "all") {
    const loc = allLocsArray[locIndex + 1] ?? allLocsArray[0];  // Sequential
    setLatLong(loc);
}
```

### After (next round):
```javascript
if (gameOptions.location === "all") {
    // Pick a random location instead of sequential access
    const availableLocs = allLocsArray.filter((l) => l.lat !== latLong.lat || l.long !== latLong.long);
    const loc = availableLocs[Math.floor(Math.random() * availableLocs.length)] || allLocsArray[0];
    setLatLong(loc);
}
```

## Impact
- ✅ Each game now shows different random locations
- ✅ No more predictable sequences
- ✅ Works consistently across different computers
- ✅ Still prevents immediate repeats within the same game

## Testing
After deploying, verify:
1. Start a new singleplayer game with "all countries"
2. Play multiple rounds - locations should be different each time
3. Start a new game - should see different locations than previous game
4. Test on different computers - should see different locations

