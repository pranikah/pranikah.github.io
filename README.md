# pranikah - Aplikasi Persiapan Nikah

Wedding Preparation Planner App built with Flutter.

---

## Prerequisites

### 1. Flutter SDK

Download: https://docs.flutter.dev/get-started/install/windows

Pastikan `flutter` ada di PATH:
```
C:\flutter\bin
```

Verifikasi:
```powershell
flutter --version
```

### 2. Android Studio + SDK

Download: https://developer.android.com/studio

Setelah install Android Studio:

1. Buka Android Studio → **More Actions** → **SDK Manager**
2. Tab **SDK Platforms**: centang **Android 14 (API 34)** atau terbaru
3. Tab **SDK Tools**: centang:
   - ✅ Android SDK Build-Tools
   - ✅ Android SDK Command-line Tools (latest)
   - ✅ Android SDK Platform-Tools
   - ✅ Android Emulator (opsional)
4. Klik **Apply**

### 3. Environment Variables (Windows)

Buka **Settings → System → About → Advanced System Settings → Environment Variables**

Tambahkan di **System Variables**:

| Variable | Value |
|----------|-------|
| `ANDROID_HOME` | `C:\Users\<username>\AppData\Local\Android\Sdk` |
| `JAVA_HOME` | `C:\Program Files\Android\Android Studio\jbr` |

Tambahkan ke **PATH**:
```
%ANDROID_HOME%\platform-tools
%ANDROID_HOME%\cmdline-tools\latest\bin
%JAVA_HOME%\bin
```

> ⚠️ Ganti `<username>` dengan username Windows kamu.

### 4. Flutter Config & Licenses

```powershell
flutter config --android-sdk "%LOCALAPPDATA%\Android\Sdk"
flutter doctor --android-licenses
```

Tekan `y` untuk accept semua licenses.

### 5. Verifikasi Setup

```powershell
flutter doctor
```

Pastikan semua ✅ (kecuali Visual Studio jika tidak develop Windows app).

---

## Getting Started

```powershell
flutter pub get
flutter run -d chrome        # Run di browser
flutter run -d emulator      # Run di Android emulator
```

---

## Build & Deploy

### Build Web (GitHub Pages)

```powershell
flutter clean
flutter pub get
flutter build web --base-href /app/ --release
```

> ⚠️ If using Git Bash, prefix with `MSYS_NO_PATHCONV=1` to avoid path conversion.

### Build Android (APK/AAB)

```powershell
# APK untuk testing
flutter build apk --release

# AAB untuk Play Store
flutter build appbundle --release
```

Output:
- APK: `build/app/outputs/flutter-apk/app-release.apk`
- AAB: `build/app/outputs/bundle/release/app-release.aab`

### Deploy to GitHub Pages

```powershell
robocopy build\web docs\app /MIR
git add .
git commit -m "deploy"
git push
```

---

## Struktur Project

```
pranikah/
├── lib/
│   ├── main.dart               ← Entry point
│   ├── models/                 ← Data models
│   ├── providers/              ← State management (Provider)
│   ├── screens/                ← UI screens
│   ├── services/               ← Business logic & storage
│   ├── theme/                  ← App theme
│   ├── widgets/                ← Reusable widgets
│   └── l10n/                   ← Localization (EN/ID)
├── web/
│   └── index.html              ← Web entry (AdSense, SEO)
├── android/                    ← Android native config
├── docs/                       ← GitHub Pages (deployed site)
│   ├── index.html              ← Landing page (AdSense)
│   ├── design-undangan.html    ← Halaman design undangan
│   ├── privacy-policy.html     ← Privacy policy
│   ├── ads.txt                 ← AdSense verification
│   └── app/                    ← Flutter web build output
└── pubspec.yaml
```

---

## AdSense Setup

- Landing page (`docs/index.html`) → Manual ad slots (`4480652123`)
- Flutter app (`docs/app/index.html`) → Auto Ads only (script di head)
- `ads.txt` di root docs untuk verifikasi

---

## Play Store Publishing

1. Daftar Google Play Console ($25 sekali bayar)
2. Buat keystore untuk signing:
   ```powershell
   keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```
3. Closed testing: minimal 20 tester, 14 hari
4. Upload AAB ke Play Console
5. Setelah 14 hari → request Production access

---

## Tech Stack

- **Flutter 3.x** (Dart)
- **Provider** - State management
- **SharedPreferences** - Local storage
- **intl** - Localization & formatting
- **url_launcher** - External links
- **GitHub Pages** - Hosting
- **Google AdSense** - Monetization

 https://github.com/pranikah/pranikah.github.io/releases/new