# Setting Up Google OAuth

## Step 1: Go to Google Cloud Console
1. Go to https://console.cloud.google.com/
2. Sign in with your Google account

## Step 2: Create a New Project (or select existing)
1. Click the project dropdown at the top
2. Click **"New Project"**
3. Name it: `WorldGuessr` (or any name)
4. Click **"Create"**
5. Wait a few seconds, then select the new project

## Step 3: Enable Google+ API
1. Go to **"APIs & Services"** → **"Library"** (left sidebar)
2. Search for **"Google+ API"**
3. Click on it and click **"Enable"**

## Step 4: Create OAuth 2.0 Credentials
1. Go to **"APIs & Services"** → **"Credentials"** (left sidebar)
2. Click **"+ CREATE CREDENTIALS"** at the top
3. Select **"OAuth client ID"**
4. If prompted, configure the OAuth consent screen first:
   - User Type: **External** (unless you have a Google Workspace)
   - App name: `WorldGuessr`
   - User support email: Your email
   - Developer contact: Your email
   - Click **"Save and Continue"**
   - Scopes: Click **"Save and Continue"** (default is fine)
   - Test users: Click **"Save and Continue"** (skip for now)
   - Summary: Click **"Back to Dashboard"**

5. Now create the OAuth client:
   - Application type: **Web application**
   - Name: `WorldGuessr Web Client`
   - **Authorized JavaScript origins:**
     - Add: `http://167.99.103.198`
     - Add: `https://167.99.103.198` (if you have SSL)
     - Add: `http://localhost:3000` (for local dev)
   - **Authorized redirect URIs:**
     - Add: `http://167.99.103.198/api/googleAuth`
     - Add: `http://localhost:3000/api/googleAuth` (for local dev)
   - Click **"Create"**

## Step 5: Copy Your Credentials
1. A popup will show your **Client ID** and **Client Secret**
2. **SAVE THESE IMMEDIATELY** - you won't see the secret again!
3. If you lose the secret, you'll need to create a new OAuth client

## Your Credentials:
- **Client ID**: Looks like `123456789-abcdefghijklmnop.apps.googleusercontent.com`
- **Client Secret**: Looks like `GOCSPX-abcdefghijklmnopqrstuvwxyz`

Save these - you'll need them for your `.env` file!

## Important Notes:
- The redirect URI must match exactly: `http://167.99.103.198/api/googleAuth`
- If you get a domain later, update the authorized origins and redirect URIs
- For production, you'll want to add your domain to authorized origins

