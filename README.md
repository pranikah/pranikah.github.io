# pra_nikah_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

## Build & Deploy

```bash
flutter clean
flutter pub get
flutter build web --base-href /app/ --release
```

> ⚠️ If using Git Bash, prefix with `MSYS_NO_PATHCONV=1` to avoid path conversion.

### Deploy to GitHub Pages

```bash
robocopy build\web docs\app /MIR
git add .
git commit -m "deploy"
git push
```

### Struktur docs/

```
docs/
├── index.html              ← Landing page (AdSense)
├── design-undangan.html    ← Halaman design undangan (AdSense)
├── privacy-policy.html     ← Privacy policy
├── ads.txt
├── app/                    ← Flutter app (build output)
│   └── index.html
│   └── main.dart.js
│   └── ...
```

> ⚠️ `robocopy /MIR` hanya menimpa `docs/app/`. Halaman statis di root `docs/` tidak terhapus.