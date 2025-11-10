# Deploying the Next.js frontend on Vercel

This project contains a monorepo-style codebase. The public-facing UI is a Next.js application, but the REST API (`server.js`) and WebSocket gateway (`ws/ws.js`) are long‑running Node services that Vercel cannot host. Follow the outline below to deploy the UI on Vercel while keeping the API/WebSocket infrastructure elsewhere.

## 1. Prepare the backend

1. **Pick a host** (Render, Railway, Fly.io, a VPS, etc.) that supports persistent Node processes.
2. Deploy the Express API (`server.js`) and WebSocket server (`ws/ws.js`) there.
   - Set `API_PORT`/`WS_PORT` (or rely on defaults) and bind to `0.0.0.0`.
   - Expose the Express server via HTTPS and the WebSocket server via WSS (use a proxy such as Nginx/Caddy if needed).
3. Copy any required environment variables (e.g. `MONGODB`, `GOOGLE_CLIENT_SECRET`, OAuth keys) to that host.
4. Ensure CORS on the API/WebSocket server allows requests from your Vercel domain (e.g. `https://<project>.vercel.app`).

## 2. Configure the frontend

1. Push the repository to GitHub/GitLab/Bitbucket (the same repo you imported in Vercel).
2. Make sure the following public environment variables are available when the app runs:

   | Variable | Description |
   | --- | --- |
   | `NEXT_PUBLIC_API_URL` | Base URL of the deployed Express API (e.g. `https://api.example.com`). |
   | `NEXT_PUBLIC_WS_HOST` | Hostname (and optional port/path) of the WebSocket gateway, without the protocol (e.g. `ws.example.com`). The client prepends `wss://` automatically in production. |

   Optional defaults are applied automatically when these values are missing (`localhost` ports for local development), but production should always define both.

3. If you need additional public configuration (analytics keys, flags, etc.), set those as `NEXT_PUBLIC_*` variables too. Any private secrets that belong to the API remain on the backend host – **do not** place them in Vercel.

## 3. Create the project in Vercel

1. In the Vercel dashboard click **New Project** and pick your repository.
2. Accept the defaults for a Next.js app:
   - **Framework preset**: Next.js
   - **Build command**: `npm run build`
   - **Output directory**: `.next`
3. Add the required environment variables from step 2 in the **Environment Variables** section (repeat for Preview/Production environments as needed).
4. Click **Deploy**. Vercel will build the Next.js frontend and serve it from the edge.

## 4. Post-deployment checklist

- Open the preview deployment URL and verify that:
  - Pages render correctly.
  - REST calls hit the external API without CORS/auth issues.
  - WebSocket connections upgrade to WSS successfully.
- Configure a custom domain in Vercel if desired.
- Keep your backend host running and monitor logs for API/WebSocket traffic.

## Local development recap

- Run `npm run dev` to start the multi-process development stack on port 3000.
- The API listens on `http://localhost:3001` and the WebSocket server on `ws://localhost:3002/wg`.
- When testing Vercel builds locally (e.g. `npm run build && npm run start`), set the same environment variables you configured in Vercel so the frontend talks to the remote backend.

With this split deployment you can iterate on the UI using Vercel’s Git-driven workflow while keeping the game API infrastructure under your control.

