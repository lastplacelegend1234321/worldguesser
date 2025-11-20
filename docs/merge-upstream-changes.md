# How to Merge Upstream Changes While Preserving Your Customizations

This guide shows you how to pull updates from the original WorldGuessr repository (`codergautam/worldguessr`) while keeping all your custom changes (rebranding to ProGuessr.com, deployment configs, etc.).

## Step 1: Add Upstream Remote

First, add the original repository as an "upstream" remote:

```bash
git remote add upstream https://github.com/codergautam/worldguessr.git
```

Verify it was added:
```bash
git remote -v
```

You should see:
```
origin    git@github.com:lastplacelegend1234321/worldguesser.git (fetch)
origin    git@github.com:lastplacelegend1234321/worldguesser.git (push)
upstream  https://github.com/codergautam/worldguessr.git (fetch)
upstream  https://github.com/codergautam/worldguessr.git (push)
```

## Step 2: Fetch Upstream Changes

Get the latest changes from upstream (without merging yet):

```bash
git fetch upstream
```

## Step 3: Check What Changed

See what branches are available:
```bash
git branch -r | grep upstream
```

Usually you'll want to merge `upstream/master`:
```bash
git log HEAD..upstream/master --oneline
```

This shows commits in upstream that you don't have yet.

## Step 4: Merge Strategy

### Option A: Merge (Recommended for First Time)

This creates a merge commit that combines both histories:

```bash
# Make sure you're on your master branch
git checkout master

# Merge upstream changes
git merge upstream/master --no-edit
```

If there are conflicts, Git will pause and show you which files have conflicts.

### Option B: Rebase (Cleaner History, More Complex)

This replays your commits on top of upstream:

```bash
git rebase upstream/master
```

**Warning**: Rebase rewrites history. Only use if you haven't pushed to origin yet, or if you're comfortable with force-pushing.

## Step 5: Resolve Conflicts

When conflicts occur, Git will mark them in the files. You'll see:

```
<<<<<<< HEAD
Your custom code (ProGuessr.com branding, etc.)
=======
Original code from upstream
>>>>>>> upstream/master
```

### Strategy for Common Conflicts:

1. **Rebranding Conflicts** (WorldGuessr → ProGuessr.com):
   - Keep your ProGuessr.com version
   - Example: If upstream has "WorldGuessr" and you have "ProGuessr.com", keep "ProGuessr.com"

2. **Configuration Conflicts**:
   - Keep your production configs (DigitalOcean, Nginx, etc.)
   - But merge new features from upstream

3. **New Features from Upstream**:
   - Accept upstream's new code
   - Then manually rebrand if needed

### Resolving Conflicts:

1. Open the conflicted file in your editor
2. Find the conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
3. Edit to keep what you want (usually your custom code)
4. Remove the conflict markers
5. Save the file

Then mark as resolved:
```bash
git add <resolved-file>
```

Continue the merge:
```bash
git commit
```

## Step 6: Test Everything

After merging, test thoroughly:

```bash
# Build the project
npm run build

# Check for errors
npm run lint  # if you have linting

# Test locally
npm run dev
```

## Step 7: Push to Your Repository

Once everything works:

```bash
git push origin master
```

## Step 8: Deploy to Server

On your DigitalOcean server:

```bash
cd ~/worldguesser
git pull origin master
npm install  # In case new dependencies were added
npm run build
pm2 restart all
```

## Automated Merge Script

Create a script to automate this process:

```bash
#!/bin/bash
# File: merge-upstream.sh

set -e  # Exit on error

echo "🔄 Fetching upstream changes..."
git fetch upstream

echo "📊 Checking for new commits..."
COMMITS=$(git log HEAD..upstream/master --oneline | wc -l)

if [ "$COMMITS" -eq 0 ]; then
    echo "✅ No new changes from upstream"
    exit 0
fi

echo "📝 Found $COMMITS new commits from upstream"
echo "🔀 Merging upstream/master..."
git merge upstream/master --no-edit

echo "✅ Merge complete! Review conflicts if any, then:"
echo "   1. Test: npm run build"
echo "   2. Commit any fixes: git commit"
echo "   3. Push: git push origin master"
```

Make it executable:
```bash
chmod +x merge-upstream.sh
```

## Best Practices

1. **Merge Regularly**: Don't let too many changes accumulate
2. **Test Before Pushing**: Always test after merging
3. **Keep a Backup**: Create a backup branch before merging:
   ```bash
   git branch backup-before-merge
   ```
4. **Document Your Changes**: Keep a list of files you've customized so you know what to watch for conflicts

## Files You've Customized (Keep These)

Based on your changes, watch for conflicts in:
- `components/home.js` - Online counter, button placement
- `components/settingsModal.js` - Custom settings
- `components/ui/accountBtn.js` - Account button
- `styles/globals.scss` - Mobile responsiveness, overflow fixes
- `public/manifest.json` - PWA branding
- `components/Seo.js` - SEO titles
- `public/locales/en/common.json` - All "ProGuessr.com" rebranding
- `next.config.js` - PWA configuration
- `pages/_app.js` - Service worker registration
- `api/map/mapHome.js` - Cache durations (you just fixed this)
- All deployment files (Nginx, PM2, etc.)

## If Something Goes Wrong

### Undo a Merge:
```bash
git merge --abort  # Before committing
# OR
git reset --hard HEAD~1  # After committing (destructive!)
```

### See What Changed:
```bash
git diff HEAD upstream/master
```

### Check Your Customizations:
```bash
git diff upstream/master HEAD
```

