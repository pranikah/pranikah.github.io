# Setup Freemium - Firebase Auth + Firestore

## Arsitektur

```
User (free) ──→ App (fitur dasar)
User (bayar) ──→ Transfer ──→ Admin verify ──→ Firestore update ──→ Fitur premium terbuka
```

## Firestore Structure

```
premium_users/{uid}
├── is_active: bool
├── activated_at: Timestamp
└── expires_at: Timestamp (opsional, null = lifetime)
```

## Alur Aktivasi Premium (Manual)

1. User **login** di app dengan Google Sign-In
2. User **transfer** ke rekening/QRIS kamu
3. User **kirim bukti** transfer via WA/Telegram beserta email Google yang dipakai login
4. Admin **cari UID** user di Firebase Console → Authentication
5. Admin **buat document** di Firestore:

   ```
   Collection: premium_users
   Document ID: {uid user}
   Fields:
     is_active: true
     activated_at: (timestamp sekarang)
     expires_at: null  ← atau set tanggal jika mau expired
   ```

6. App otomatis detect perubahan (realtime stream) → fitur premium terbuka

## Cara Pakai di Code

### Wrap fitur premium dengan PremiumGate:

```dart
import 'package:pra_nikah_app/widgets/premium_gate.dart';

// Di screen manapun:
PremiumGate(
  child: AdvancedBudgetAnalytics(),  // fitur premium
)
```

### Cek premium secara programmatic:

```dart
final premiumService = PremiumService();
final isPremium = await premiumService.isPremium(user.uid);
```

## Setup Firebase (Jika belum)

1. Buat project di [Firebase Console](https://console.firebase.google.com)
2. Enable **Authentication** → Sign-in method → Google
3. Buat **Firestore Database** (start in production mode)
4. Tambahkan Firestore Rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admin email list
    function isAdmin() {
      return request.auth != null &&
        request.auth.token.email in ['leimportant@gmail.com'];
    }

    // Premium users: user baca milik sendiri, admin bisa read/write semua
    match /premium_users/{uid} {
      allow read: if request.auth != null && (request.auth.uid == uid || isAdmin());
      allow create: if request.auth != null && request.auth.uid == uid;
      allow update: if isAdmin();
    }
    
    // Rules existing untuk wedding plans
    match /wedding_plans/{planId} {
      allow read, write: if true; // sesuaikan dengan kebutuhan
      match /{sub=**} {
        allow read, write: if true;
      }
    }
  }
}
```

5. Untuk **web (GitHub Pages)**, tambahkan domain `username.github.io` di:
   - Firebase Console → Authentication → Settings → Authorized domains

## Deploy ke GitHub Pages

```bash
flutter build web --base-href "/pra-nikah-app/"
# Deploy folder build/web ke branch gh-pages
```

## File yang Ditambahkan

| File | Fungsi |
|------|--------|
| `lib/services/auth_service.dart` | Google Sign-In login/logout |
| `lib/services/premium_service.dart` | Cek status premium dari Firestore |
| `lib/models/premium_user.dart` | Model data premium user |
| `lib/widgets/premium_gate.dart` | Widget wrapper lock/unlock fitur |
