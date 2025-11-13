# Creating Droplet via DigitalOcean API

## Step 1: Get Your API Token

1. Go to [DigitalOcean API Tokens](https://cloud.digitalocean.com/account/api/tokens)
2. Click **"Generate New Token"**
3. Give it a name: `worldguessr-deploy`
4. Select **"Write"** scope (or leave default)
5. Click **"Generate Token"**
6. **Copy the token immediately** (you won't see it again!)

## Step 2: Set the Token

```bash
export DO_TOKEN=your_token_here
```

Or add it to your `~/.bashrc` or `~/.zshrc`:
```bash
echo 'export DO_TOKEN=your_token_here' >> ~/.bashrc
source ~/.bashrc
```

## Step 3: Create Droplet

### Option A: Use the Script (Recommended)

```bash
# Set token
export DO_TOKEN=your_token_here

# Create droplet with defaults
./scripts/create-droplet.sh

# Or customize:
DROPLET_NAME=worldguessr-prod \
DROPLET_SIZE=s-4vcpu-8gb \
DROPLET_REGION=nyc1 \
./scripts/create-droplet.sh
```

### Option B: Use curl Directly

```bash
curl -X POST \
    -H 'Content-Type: application/json' \
    -H "Authorization: Bearer $DO_TOKEN" \
    -d '{
        "name":"worldguessr-production",
        "size":"s-2vcpu-2gb",
        "region":"sfo2",
        "image":"ubuntu-22-04-x64"
    }' \
    "https://api.digitalocean.com/v2/droplets"
```

## Available Sizes

- `s-1vcpu-1gb` - $6/month (1GB RAM, 1 vCPU) - **Minimum**
- `s-2vcpu-2gb` - $12/month (2GB RAM, 2 vCPU) - **Recommended for testing**
- `s-4vcpu-8gb` - $48/month (8GB RAM, 4 vCPU) - **Production**

## Available Regions

- `nyc1`, `nyc3` - New York
- `sfo2`, `sfo3` - San Francisco
- `ams3` - Amsterdam
- `sgp1` - Singapore
- `lon1` - London
- `fra1` - Frankfurt
- `tor1` - Toronto
- `blr1` - Bangalore
- `syd1` - Sydney

Choose the region closest to your users!

## Available Images

- `ubuntu-22-04-x64` - Ubuntu 22.04 LTS (Recommended)
- `ubuntu-20-04-x64` - Ubuntu 20.04 LTS
- `ubuntu-24-04-x64` - Ubuntu 24.04 LTS

## After Droplet Creation

The script will output:
- Droplet ID
- IP Address
- SSH command

Then follow: `docs/digitalocean-quickstart.md`

## Troubleshooting

**"Unauthorized" error?**
- Check your token is correct
- Make sure token has "Write" scope

**"Image not found" error?**
- Use `ubuntu-22-04-x64` (not `ubuntu-25-10-x64`)
- Check available images: `curl -H "Authorization: Bearer $DO_TOKEN" "https://api.digitalocean.com/v2/images?type=distribution"`

**"Size not available in region" error?**
- Try a different region
- Check available sizes: `curl -H "Authorization: Bearer $DO_TOKEN" "https://api.digitalocean.com/v2/sizes"`

