# PromptMaster Frontend

Flutter web app for PromptMaster. The production app is Firebase-only: Firebase
Authentication handles Google login, Firestore enforces the intern allowlist,
and Firebase Hosting serves the static Flutter build. Prompt templates are
generated locally, so no FastAPI server is required.

**Live:** https://asdasdasdasdasdasdertghrh.web.app

## Setup

```bash
flutter pub get
dart pub global activate flutterfire_cli
firebase login
flutterfire configure
```

`flutterfire configure` generates `lib/firebase_options.dart` for your Firebase project.

Enable **Google** sign-in in Firebase Console → Authentication → Sign-in method.

Add `localhost` and your Firebase Hosting domain under Authentication → Settings
→ Authorized domains.

## Run locally

```bash
flutter run -d chrome --web-port=3000
```

## Allow an intern

Create a document in the `intern_allowlist` Firestore collection:

- Document ID: the lowercase Google email address
- `email`: the same lowercase address
- `active`: `true`
- `name`: display name (optional)

Firestore rules only let a signed-in, email-verified user read their own active
allowlist document. Browsing or editing the collection from the app is denied.

## Test and deploy

```bash
flutter analyze --no-fatal-infos
flutter test
flutter build web --release --base-href /
firebase deploy --only firestore:rules,hosting
```

The current setup fits Firebase's Spark free tier for a small internal app,
provided usage stays within the published free quotas.

## Monorepo

This project is also linked from the umbrella repo:

```bash
git clone --recurse-submodules git@github.com:Siddiqui-Shahid/promptMaster.git
```
