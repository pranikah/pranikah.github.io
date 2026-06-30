import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service untuk mengelola Interstitial Ad.
/// Menampilkan iklan full-screen pada transisi natural (pindah tab setiap N kali).
class InterstitialAdService {
  InterstitialAd? _interstitialAd;
  bool _isAdReady = false;
  int _tabSwitchCount = 0;

  // Tampilkan interstitial setiap N kali pindah tab
  static const int _showEveryNTabs = 4;

  // Production: ca-app-pub-6781504523102344/8201791744
  // Test:       ca-app-pub-3940256099942544/1033173712
  static const String _adUnitId = 'ca-app-pub-6781504523102344/8201791744';

  /// Load interstitial ad
  void loadAd() {
    if (kIsWeb) return;

    InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isAdReady = true;

          _interstitialAd!.fullScreenContentCallback =
              FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isAdReady = false;
              _interstitialAd = null;
              // Pre-load next ad setelah ditutup
              loadAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              debugPrint('Interstitial failed to show: ${error.message}');
              ad.dispose();
              _isAdReady = false;
              _interstitialAd = null;
              loadAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint('Interstitial failed to load: ${error.message}');
          _isAdReady = false;
        },
      ),
    );
  }

  /// Dipanggil saat user pindah tab.
  /// Menampilkan interstitial setiap [_showEveryNTabs] kali pindah tab.
  void onTabSwitch() {
    if (kIsWeb) return;

    _tabSwitchCount++;
    if (_tabSwitchCount >= _showEveryNTabs) {
      _tabSwitchCount = 0;
      showAd();
    }
  }

  /// Tampilkan interstitial ad jika sudah ready
  void showAd() {
    if (_isAdReady && _interstitialAd != null) {
      _interstitialAd!.show();
    }
  }

  /// Dispose resources
  void dispose() {
    _interstitialAd?.dispose();
    _interstitialAd = null;
    _isAdReady = false;
  }
}
