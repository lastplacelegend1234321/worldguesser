# Setting Up MongoDB Atlas

## Step 1: Create Account
1. Go to https://www.mongodb.com/cloud/atlas/register
2. Sign up for a free account

## Step 2: Create a Free Cluster
1. Click **"Build a Database"**
2. Choose **"M0 FREE"** (Free tier)
3. Select a cloud provider (AWS, Google Cloud, or Azure)
4. Choose a region closest to your DigitalOcean droplet (e.g., if your droplet is in San Francisco, choose a US region)
5. Click **"Create"**
6. Wait 3-5 minutes for cluster to be created

## Step 3: Create Database User
1. Go to **"Database Access"** (left sidebar)
2. Click **"Add New Database User"**
3. Choose **"Password"** authentication
4. Enter a username (e.g., `worldguessr`)
5. Click **"Autogenerate Secure Password"** or create your own
6. **SAVE THE PASSWORD** - you won't see it again!
7. Under "Database User Privileges", select **"Atlas admin"** or **"Read and write to any database"**
8. Click **"Add User"**

## Step 4: Whitelist Your IP
1. Go to **"Network Access"** (left sidebar)
2. Click **"Add IP Address"**
3. Click **"Allow Access from Anywhere"** (adds `0.0.0.0/0`)
   - OR add your droplet IP: `167.99.103.198`
4. Click **"Confirm"**

## Step 5: Get Connection String
1. Go to **"Database"** (left sidebar)
2. Click **"Connect"** on your cluster
3. Choose **"Connect your application"**
4. Driver: **Node.js**, Version: **5.5 or later**
5. Copy the connection string (looks like: `mongodb+srv://<username>:<password>@cluster0.xxxxx.mongodb.net/?retryWrites=true&w=majority`)
6. Replace `<username>` with your database username
7. Replace `<password>` with your database password (URL encode special characters like `@` becomes `%40`)
8. Add database name at the end: `mongodb+srv://username:password@cluster0.xxxxx.mongodb.net/worldguessr?retryWrites=true&w=majority`

## Your MongoDB Connection String Format:
```
mongodb+srv://YOUR_USERNAME:YOUR_PASSWORD@cluster0.xxxxx.mongodb.net/worldguessr?retryWrites=true&w=majority
```

Save this - you'll need it for your `.env` file!

