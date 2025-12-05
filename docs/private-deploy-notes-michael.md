## Michael's deploy notes (ProGuessr)

This is a **personal cheat sheet** for how to push changes to GitHub and deploy them to the DigitalOcean droplet.

---

### 1. Local: commit and push to GitHub

From your Mac:

```bash
cd /Users/michaelpritsky/Desktop/worldguesserdupe/worldguessr

git status                      # see what changed
git add .                       # or git add <specific_files>
git commit -m "Your message here"

# IMPORTANT: push HEAD explicitly to the branch (branch name == tag name)
git push origin HEAD:refs/heads/proguessr-pwa-stable-2025-11-20
```

You can confirm the remote branch has your latest commit with:

```bash
git fetch origin
git log -1 --oneline
git log -1 --oneline origin/proguessr-pwa-stable-2025-11-20
```

The two `git log` lines should show the same commit hash and message.

---

### 2. Droplet: pull, build, restart (normal deploy)

SSH into the droplet **as root**:

```bash
ssh root@167.99.103.198
```

Then run:

```bash
cd ~/worldguesser

git pull origin proguessr-pwa-stable-2025-11-20

npm install
npm run build

pm2 restart all
```

This pulls the latest code, installs any new dependencies, rebuilds the Next.js app, and restarts:

- `worldguessr-api`
- `worldguessr-cron`
- `worldguessr-ws`

You can verify PM2 is happy with:

```bash
pm2 ls
```

---

### 3. Quick verification (example: manifest)

To sanity-check that the live site is serving the latest files (e.g. `manifest.json`):

```bash
curl https://proguessr.com/manifest.json
```

Look for your recent changes (for example, the `1920x1080` icon entry in the `icons` array).

---

### 4. Emergency "hard reset" if droplet repo gets messy

If `git status` on the droplet shows a bunch of local changes or weird backup files and you just want to force it to match GitHub:

```bash
cd ~/worldguesser

git fetch origin
git reset --hard origin/proguessr-pwa-stable-2025-11-20
git clean -fd        # WARNING: deletes untracked files in this repo

npm install
npm run build
pm2 restart all
```

Only use this if you are sure you don’t have any important uncommitted changes on the droplet.


