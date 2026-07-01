import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateCheckerService {
  static const String _repoOwner = 'pranikah';
  static const String _repoName = 'pranikah.github.io';
  static const String _apiUrl =
      'https://api.github.com/repos/$_repoOwner/$_repoName/releases/latest';

  /// Check for updates and show dialog if new version available
  static Future<void> checkForUpdate(BuildContext context) async {
    // Skip on web
    if (kIsWeb) return;

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; // e.g. "1.0.0"

      final response = await http.get(
        Uri.parse(_apiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final tagName = data['tag_name'] as String? ?? '';
      // Remove 'v' prefix if present: "v1.1.0" -> "1.1.0"
      final latestVersion = tagName.startsWith('v') ? tagName.substring(1) : tagName;

      if (_isNewerVersion(latestVersion, currentVersion)) {
        // Find APK download URL
        final assets = data['assets'] as List<dynamic>? ?? [];
        String? apkUrl;
        for (final asset in assets) {
          final name = (asset['name'] as String? ?? '').toLowerCase();
          if (name.endsWith('.apk')) {
            apkUrl = asset['browser_download_url'] as String?;
            break;
          }
        }

        // Fallback to release page
        apkUrl ??= data['html_url'] as String? ??
            'https://github.com/$_repoOwner/$_repoName/releases/latest';

        final body = data['body'] as String? ?? '';

        if (context.mounted) {
          _showUpdateDialog(context, latestVersion, apkUrl, body);
        }
      }
    } catch (e) {
      // Silent fail - don't bother user if check fails
      debugPrint('Update check failed: $e');
    }
  }

  /// Compare versions: returns true if latest > current
  static bool _isNewerVersion(String latest, String current) {
    try {
      final latestParts = latest.split('.').map(int.parse).toList();
      final currentParts = current.split('.').map(int.parse).toList();

      // Pad to same length
      while (latestParts.length < 3) latestParts.add(0);
      while (currentParts.length < 3) currentParts.add(0);

      for (int i = 0; i < 3; i++) {
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return false; // Same version
    } catch (e) {
      return false;
    }
  }

  /// Show bottom sheet update dialog
  static void _showUpdateDialog(
    BuildContext context,
    String version,
    String downloadUrl,
    String changelog,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            // Icon
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.system_update, size: 32, color: Colors.green.shade600),
            ),
            const SizedBox(height: 16),
            // Title
            Text(
              'Update Tersedia! 🎉',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Versi $version sudah tersedia',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
            ),
            // Changelog
            if (changelog.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                constraints: const BoxConstraints(maxHeight: 120),
                child: SingleChildScrollView(
                  child: Text(
                    changelog,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700, height: 1.5),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // Buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  _openDownload(downloadUrl);
                },
                icon: const Icon(Icons.download),
                label: const Text('Download Update'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'Nanti saja',
                  style: TextStyle(color: Colors.grey.shade500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Open download URL in browser
  static Future<void> _openDownload(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
