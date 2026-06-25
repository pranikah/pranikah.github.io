# pra_nikah_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

## Build & Deploy

```bash
flutter clean
flutter pub get
flutter build web --base-href / --release
```

> ⚠️ If using Git Bash, prefix with `MSYS_NO_PATHCONV=1` to avoid path conversion.

### Deploy to GitHub Pages

```bash
robocopy build\web docs /MIR
git add .
git commit -m "fix admin bank account"
git push
```