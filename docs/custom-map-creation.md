# Custom Map Creation Guide

## Can Users Create Custom Maps?

**Yes!** Users can create custom maps on Proguessr. Here's how it works:

## How to Create a Custom Map

### Prerequisites
- **Must be logged in** - Users need a Google account and must sign in
- **Rate limit**: Users can create 1 map per hour

### Steps to Create a Map

1. **Access the Maps Modal**
   - Click on "Custom Maps" or "Maps" button from the home screen
   - Or access it when selecting a map for a game

2. **Click "Make Map" Button**
   - Look for the "+ Make Map" button in the maps interface
   - This opens the map creation form

3. **Fill in Map Details**
   - **Name** (required): Descriptive name for your map (min 3, max 50 characters)
   - **Short Description** (required): Brief description (min 10, max 100 characters)
   - **Long Description** (optional): Detailed description (max 500 characters)

4. **Add Locations**
   You can add locations in two ways:

   **Option A: Upload a File**
   - Click "Upload File" button
   - Upload a `.txt` or `.json` file with location data
   - File format: One location per line, either:
     - Google Maps URLs: `https://www.google.com/maps/@LAT,LNG,Z`
     - JSON format: `{"lat": LAT, "lng": LNG}`
     - Coordinates: `LAT,LNG`

   **Option B: Manual Entry**
   - Click "Add URL" to add location fields
   - Enter Google Maps URLs or coordinates for each location
   - Minimum: 5 locations required
   - Maximum: 5000 locations allowed

5. **Submit the Map**
   - Click "Create Map" button
   - Map will be created and immediately accepted (no review process)
   - You'll see a success message

## Map Creation Rules

- ✅ Use descriptive names
- ✅ Provide helpful descriptions
- ✅ Add at least 5 locations
- ✅ Keep all content in English
- ✅ No NSFW content
- ✅ Maximum 5000 locations per map
- ⚠️ Rate limit: 1 map per hour per user

## Technical Details

### API Endpoint
- **URL**: `/api/map/action`
- **Method**: POST
- **Auth**: Requires `secret` token (user must be logged in)
- **Action**: `create` or `edit`

### Map Data Format
Locations can be provided as:
- Google Maps URLs: `https://www.google.com/maps/@40.7128,-74.0060,15z`
- JSON objects: `{"lat": 40.7128, "lng": -74.0060}`
- Coordinate pairs: `40.7128,-74.0060`

### Map Properties
- `slug`: Auto-generated from name
- `name`: User-provided name
- `description_short`: Brief description
- `description_long`: Detailed description (optional)
- `data`: Array of location objects with `lat` and `lng`
- `created_by`: User ID
- `map_creator_name`: Username
- `accepted`: Always `true` (no review needed)
- `in_review`: Always `false`
- `plays`: Starts at 0
- `hearts`: Starts at 0

## Finding Your Created Maps

After creating a map:
1. Go to Maps modal
2. Look in "My Maps" section (if logged in)
3. Your maps will appear at the top of the list
4. You can edit them by clicking on them

## Editing Maps

- Click on your map in "My Maps"
- Click "Edit Map" button
- Modify name, descriptions, or locations
- Click "Save Changes"
- Same rate limit applies (1 edit per hour)

## Troubleshooting

### "Not logged in" error
- Make sure you're signed in with Google
- Refresh the page and try again

### "Need at least 5 locations" error
- Add more locations to your map
- Minimum is 5 locations

### "Too many locations" error
- Reduce locations to 5000 or fewer
- Split into multiple maps if needed

### "You can make 1 map an hour" error
- Wait an hour between map creations
- This is a rate limit to prevent spam

### File upload fails
- Check file format (should be .txt or .json)
- Ensure locations are properly formatted
- Try manual entry instead

## Example Map File Format

**locations.txt:**
```
https://www.google.com/maps/@40.7128,-74.0060,15z
https://www.google.com/maps/@51.5074,-0.1278,15z
https://www.google.com/maps/@35.6762,139.6503,15z
{"lat": 48.8566, "lng": 2.3522}
48.2082,16.3738
```

## Need Help?

- Join the Discord: https://discord.gg/azbS3F2wmb
- Check the map creation form for tips
- Contact support if you encounter issues

