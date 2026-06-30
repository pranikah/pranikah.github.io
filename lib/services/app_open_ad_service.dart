import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Service untuk mengelola App Open Ad.
/// Menampilkan iklan saat user membuka app atau kembali dari background.
class AppOpenAdService {
  AppOpenAd? _appOpenAd;
  bool _isAdAvailable = false;
  bool _isShowingAd = false;

  /// Waktu terakhir ad di-load (max 4 jam sesuai kebijakan AdMob)
  DateTime? _appOpenLoadTime;

  // Production: ca-app-pub-6781504523102344/6873196961
  // Test:       ca-app-pub-3940256099942544/9257395921
  static const String _adUnitId = 'ca-app-pub-6781504523102344/6873196961';

  /// Durasi maksimal ad valid (4 jam sesuai kebijakan AdMob)
  static const Duration _maxCacheDuration = Duration(hours: 4);

  /// Minimal waktu di background sebelum tampilkan ad (30 detik)
  static const Duration _minBackgroundDuration = Duration(seconds: 30);

  /// Waktu terakhir app ke background
  DateTime? _lastBackgroundTime;

  /// Load App Open Ad
  void loadAd() {
    if (kIsWeb) return;

    AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _appOpenAd = ad;
          _isAdAvailable = true;
          _appOpenLoadTime = DateTime.now();
          debugPrint('App Open Ad loaded');
        },
        onAdFailedToLoad: (error) {
          debugPrint('App Open Ad failed to load: ${error.message}');
          _isAdAvailable = false;
        },
      ),
    );
  }

  /// Dipanggil saat app ke background
  void onAppPaused() {
    _lastBackgroundTime = DateTime.now();
  }

  /// Dipanggil saat app kembali dari background
  void onAppResumed() {
    if (_lastBackgroundTime != null) {
      final backgroundDuration =
          DateTime.now().difference(_lastBackgroundTime!);
      if (backgroundDuration >= _minBackgroundDuration) {
        showAdIfAvailable();
      }
    }
  }

  /// Tampilkan App Open Ad jika tersedia dan belum expired
  void showAdIfAvailable() {
    if (kIsWeb) return;
    if (!_isAdAvailable) {
      loadAd();
      return;
    }
    if (_isShowingAd) return;

    // Cek apakah ad sudah expired (> 4 jam)
    if (_appOpenLoadTime != null &&
        DateTime.now().difference(_appOpenLoadTime!) > _maxCacheDuration) {
      _appOpenAd?.dispose();
      _appOpenAd = null;
      _isAdAvailable = false;
      loadAd();
      return;
    }

    _isShowingAd = true;
    _appOpenAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _isShowingAd = false;
        _isAdAvailable = false;
        ad.dispose();
        _appOpenAd = null;
        // Pre-load next ad
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('App Open Ad failed to show: ${error.message}');
        _isShowingAd = false;
        _isAdAvailable = false;
        ad.dispose();
        _appOpenAd = null;
        loadAd();
      },
    );

    _appOpenAd!.show();
  }

  /// Dispose resources
  void dispose() {
    _appOpenAd?.dispose();
    _appOpenAd = null;
    _isAdAvailable = false;
  }
}
