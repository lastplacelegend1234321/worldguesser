# 🚀 Quick Deploy Instructions

## Step 1: SSH into your server

```bash
ssh root@167.99.103.198
```

## Step 2: Upload and run the deployment script

### Option A: Copy script to server (Recommended)

On your LOCAL machine, run:

```bash
scp deploy-server.sh root@167.99.103.198:~/
```

Then SSH in and run:

```bash
ssh root@167.99.103.198
chmod +x deploy-server.sh
./deploy-server.sh
```

### Option B: Download script directly on server

SSH into your server, then:

```bash
cd ~
curl -o deploy-server.sh https://raw.githubusercontent.com/lastplacelegend1234321/worldguesser/master/deploy-server.sh
chmod +x deploy-server.sh
./deploy-server.sh
```

### Option C: Manual copy-paste

SSH into your server, then:

```bash
nano deploy-server.sh
```

Copy the entire contents of `deploy-server.sh` from your local machine, paste it, save (`Ctrl+X`, `Y`, `Enter`), then:

```bash
chmod +x deploy-server.sh
./deploy-server.sh
```

## Step 3: Edit .env file when prompted

The script will pause and ask you to edit the `.env` file. You'll need:

1. **MongoDB connection string** (from MongoDB Atlas)
2. **Google OAuth Client ID** (from Google Cloud Console)
3. **Google OAuth Client Secret** (from Google Cloud Console)

Edit it with:
```bash
nano .env
```

Then continue the script.

## That's it! 🎉

Your site will be live at: **http://167.99.103.198**

