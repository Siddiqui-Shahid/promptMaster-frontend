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

## Monorepo

This project is also linked from the umbrella repo:

```bash
git clone --recurse-submodules git@github.com:Siddiqui-Shahid/promptMaster.git
```
