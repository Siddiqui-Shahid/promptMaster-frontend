# PromptMaster Frontend

Flutter client for [PromptMaster](https://github.com/Siddiqui-Shahid/promptMaster).

**API repo:** [promptMaster-backend](https://github.com/Siddiqui-Shahid/promptMaster-backend)

## Setup

```bash
flutter pub get
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
```

`flutterfire configure` generates `lib/firebase_options.dart` for your Firebase project.

Enable **Google** sign-in in Firebase Console → Authentication → Sign-in method.

Add authorized domains: `localhost`, `siddiqui-shahid.github.io` (Authentication → Settings).

## Run (local API + Firebase Google auth)

```bash
flutter run -d chrome --web-port=3000 \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000
```

## Run (production API)

```bash
flutter run -d chrome \
  --dart-define=API_BASE_URL=https://your-api.example.com
```

- `API_BASE_URL` → FastAPI backend URL
- Firebase config lives in `lib/firebase_options.dart` (from FlutterFire CLI)

## Deploy web (GitHub Pages)

Hosting uses **GitHub Actions** only.

### One-time setup

1. **GitHub secrets** (repo → Settings → Secrets and variables → Actions):
   - `API_BASE_URL` = your deployed API URL (no trailing slash)

2. **Enable Pages** (repo → Settings → Pages → Build and deployment):
   - Source: **GitHub Actions**

3. **Railway CORS** (API service → Variables), after the first deploy:
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
