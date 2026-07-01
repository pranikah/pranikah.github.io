import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

/// Release info model
class AppReleaseInfo {
  final String version;
  final String downloadUrl;
  final String changelog;
  final String publishedAt;
  final int fileSize; // bytes
  final String currentVersion;

  AppReleaseInfo({
    required this.version,
    required this.downloadUrl,
    required this.changelog,
    required this.publishedAt,
    required this.fileSize,
    required this.currentVersion,
  });

  bool get hasUpdate => _isNewerVersion(version, currentVersion);

  static bool _isNewerVersion(String latest, String current) {
    try {
      final l = latest.split('.').map(int.parse).toList();
      final c = current.split('.').map(int.parse).toList();
      while (l.length < 3) l.add(0);
      while (c.length < 3) c.add(0);
      for (int i = 0; i < 3; i++) {
        if (l[i] > c[i]) return true;
        if (l[i] < c[i]) return false;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}

/// Download progress callback
typedef DownloadProgressCallback = void Function(int received, int total);

class UpdateCheckerService {
  static const String _repoOwner = 'pranikah';
  static const String _repoName = 'pranikah.github.io';
  static const String _apiUrl =
      'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';

  /// Check for update - returns release info or null
  static Future<AppReleaseInfo?> checkForUpdate() async {
    if (kIsWeb) return null;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      final latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;

      // Find APK asset
      final assets = data['assets'] as List<dynamic>? ?? [];
      String? apkUrl;
      int fileSize = 0;
      for (final asset in assets) {
        final name = (asset['name'] as String? ?? '').toLowerCase();
        if (name.endsWith('.apk')) {
          apkUrl = asset['browser_download_url'] as String?;
          fileSize = (asset['size'] as int?) ?? 0;
          break;
        }
      }

      apkUrl ??= data['html_url'] as String? ??
          'https://github.com/$_repoOwner/$_repoName/releases/latest';

      final releaseInfo = AppReleaseInfo(
        version: latestVersion,
        downloadUrl: apkUrl,
        changelog: data['body'] as String? ?? '',
        publishedAt: data['published_at'] as String? ?? '',
        fileSize: fileSize,
        currentVersion: currentVersion,
      );

      return releaseInfo.hasUpdate ? releaseInfo : null;
    } catch (e) {
      debugPrint('Update check failed: $e');
      return null;
    }
  }

  /// Download APK with progress tracking
  static Future<File?> downloadApk(
    String url, {
    required DownloadProgressCallback onProgress,
  }) async {
    try {
      final client = http.Client();
      final request = http.Request('GET', Uri.parse(url));
      request.headers['Cache-Control'] = 'no-cache, no-store';
      request.headers['Pragma'] = 'no-cache';
      final response = await client.send(request);

      final totalBytes = response.contentLength ?? 0;
      int receivedBytes = 0;

      final dir = await getTemporaryDirectory();
      // Use unique filename to avoid stale cache
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${dir.path}/pranikah_update_$timestamp.apk');

      // Delete old APK files first
      try {
        final files = dir.listSync();
        for (final f in files) {
          if (f is File && f.path.contains('pranikah_update') && f.path.endsWith('.apk')) {
            f.deleteSync();
          }
        }
      } catch (_) {}

      final sink = file.openWrite();

      await for (final chunk in response.stream) {
        sink.add(chunk);
        receivedBytes += chunk.length;
        onProgress(receivedBytes, totalBytes);
      }

      await sink.close();
      client.close();
      return file;
    } catch (e) {
      debugPrint('Download failed: $e');
      return null;
    }
  }
}
