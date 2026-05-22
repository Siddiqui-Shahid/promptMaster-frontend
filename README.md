# PromptMaster Frontend

Flutter client for [PromptMaster](https://github.com/Siddiqui-Shahid/promptMaster).

**API repo:** [promptMaster-backend](https://github.com/Siddiqui-Shahid/promptMaster-backend)

## Setup

```bash
flutter pub get
```

## Run (local API)

```bash
flutter run -d chrome --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## Run (production API)

```bash
flutter run -d chrome --dart-define=API_BASE_URL=https://your-api.example.com
```

API base URL is configured in `lib/core/api_config.dart` via the `API_BASE_URL` dart-define.

## Deploy web (GitHub Pages)

Hosting uses **GitHub Actions** only (no Netlify/Vercel/Railway for the frontend).

### One-time setup

1. **GitHub secret** (repo → Settings → Secrets and variables → Actions):
   - `API_BASE_URL` = your Railway API URL, e.g. `https://your-app.up.railway.app` (no trailing slash)

2. **Enable Pages** (repo → Settings → Pages → Build and deployment):
   - Source: **GitHub Actions**

3. **Private repo:** GitHub Pages on a private repo requires **GitHub Pro** (or make the repo public on Free).

4. **Railway CORS** (API service → Variables), after the first deploy:
   - `CORS_ALLOWED_ORIGINS=https://siddiqui-shahid.github.io`
   - Redeploy the API if needed

### Deploy

Push to `main`. The workflow `.github/workflows/deploy-web.yml` builds and publishes to:

`https://siddiqui-shahid.github.io/promptMaster-frontend/`

Check progress under **Actions**; the live URL appears under **Settings → Pages**.

## Monorepo

This project is also linked from the umbrella repo:

```bash
git clone --recurse-submodules git@github.com:Siddiqui-Shahid/promptMaster.git
```
