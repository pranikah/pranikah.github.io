import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/update_checker_service.dart';
import '../theme/app_theme.dart';

class UpdateScreen extends StatefulWidget {
  final AppReleaseInfo releaseInfo;

  const UpdateScreen({super.key, required this.releaseInfo});

  @override
  State<UpdateScreen> createState() => _UpdateScreenState();
}

enum _DownloadState { idle, downloading, done, error }

class _UpdateScreenState extends State<UpdateScreen>
    with SingleTickerProviderStateMixin {
  _DownloadState _state = _DownloadState.idle;
  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  File? _apkFile;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _startDownload() async {
    setState(() {
      _state = _DownloadState.downloading;
      _progress = 0.0;
    });

    final file = await UpdateCheckerService.downloadApk(
      widget.releaseInfo.downloadUrl,
      onProgress: (received, total) {
        setState(() {
          _receivedBytes = received;
          _totalBytes = total;
          _progress = total > 0 ? received / total : 0;
        });
      },
    );

    if (file != null && file.existsSync()) {
      setState(() {
        _state = _DownloadState.done;
        _apkFile = file;
      });
    } else {
      setState(() => _state = _DownloadState.error);
    }
  }

  Future<void> _installApk() async {
    // Open file with Android intent
    if (_apkFile != null) {
      // Fallback: open download URL in browser for install
      final uri = Uri.parse(widget.releaseInfo.downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
                      'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'];
      return '${date.day} ${months[date.month - 1]} ${date.year}';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Update Tersedia'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildAppHeader(),
            const Divider(height: 1),
            _buildWhatsNew(),
            const Divider(height: 1),
            _buildAppInfo(),
            const SizedBox(height: 100),
          ],
        ),
      ),
      bottomSheet: _buildBottomAction(),
    );
  }

  Widget _buildAppHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // App icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: AppTheme.secondary,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Text('💍', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(width: 16),
          // App info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'pranikah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Persiapan Nikah & Design Undangan',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildBadge(
                      '${widget.releaseInfo.currentVersion} → ${widget.releaseInfo.version}',
                      Colors.green,
                    ),
                    const SizedBox(width: 8),
                    if (widget.releaseInfo.fileSize > 0)
                      _buildBadge(
                        _formatBytes(widget.releaseInfo.fileSize),
                        Colors.blue,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color.shade700),
      ),
    );
  }

  Widget _buildWhatsNew() {
    final changelog = widget.releaseInfo.changelog;
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "What's New",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              if (widget.releaseInfo.publishedAt.isNotEmpty)
                Text(
                  _formatDate(widget.releaseInfo.publishedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (changelog.isNotEmpty)
            _buildChangelogContent(changelog)
          else
            Text(
              'Bug fixes dan peningkatan performa.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
            ),
        ],
      ),
    );
  }

  Widget _buildChangelogContent(String changelog) {
    // Parse markdown-style changelog into styled widgets
    final lines = changelog.split('\n').where((l) => l.trim().isNotEmpty).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: lines.take(20).map((line) {
        final trimmed = line.trim();

        // Heading (## or ###)
        if (trimmed.startsWith('#')) {
          final text = trimmed.replaceAll(RegExp(r'^#+\s*'), '');
          return Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 6),
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
          );
        }

        // Bullet point (- or *)
        if (trimmed.startsWith('-') || trimmed.startsWith('*')) {
          final text = trimmed.replaceFirst(RegExp(r'^[-*]\s*'), '');
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 7),
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(child: _buildRichText(text)),
              ],
            ),
          );
        }

        // Regular paragraph
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildRichText(trimmed),
        );
      }).toList(),
    );
  }

  /// Parse **bold** and render as RichText
  Widget _buildRichText(String text) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Text before bold
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
          style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700, height: 1.5),
        ));
      }
      // Bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: TextStyle(fontSize: 13.5, color: AppTheme.textDark, fontWeight: FontWeight.w600, height: 1.5),
      ));
      lastEnd = match.end;
    }

    // Remaining text after last bold
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
        style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700, height: 1.5),
      ));
    }

    if (spans.isEmpty) {
      spans.add(TextSpan(
        text: text,
        style: TextStyle(fontSize: 13.5, color: Colors.grey.shade700, height: 1.5),
      ));
    }

    return RichText(text: TextSpan(children: spans));
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Informasi App',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.textDark),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.update, 'Versi Terbaru', widget.releaseInfo.version),
          _buildInfoRow(Icons.phone_android, 'Versi Saat Ini', widget.releaseInfo.currentVersion),
          if (widget.releaseInfo.fileSize > 0)
            _buildInfoRow(Icons.storage, 'Ukuran Download', _formatBytes(widget.releaseInfo.fileSize)),
          _buildInfoRow(Icons.verified_user, 'Developer', 'pranikah'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
          ),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_state == _DownloadState.downloading) ...[
            // Progress section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Mengunduh...',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                Text(
                  '${(_progress * 100).toStringAsFixed(0)}%  •  ${_formatBytes(_receivedBytes)} / ${_formatBytes(_totalBytes)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: _progress,
                minHeight: 8,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Main action button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: _buildActionButton(),
          ),
          if (_state == _DownloadState.idle)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Nanti saja',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    switch (_state) {
      case _DownloadState.idle:
        return ElevatedButton.icon(
          onPressed: _startDownload,
          icon: const Icon(Icons.download_rounded, size: 22),
          label: const Text('Update Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
          ),
        );
      case _DownloadState.downloading:
        return ElevatedButton(
          onPressed: null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey.shade200,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 18, height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade500),
                ),
              ),
              const SizedBox(width: 12),
              Text('Mengunduh...', style: TextStyle(color: Colors.grey.shade600)),
            ],
          ),
        );
      case _DownloadState.done:
        return ElevatedButton.icon(
          onPressed: _installApk,
          icon: const Icon(Icons.install_mobile, size: 22),
          label: const Text('Install Update', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
          ),
        );
      case _DownloadState.error:
        return ElevatedButton.icon(
          onPressed: _startDownload,
          icon: const Icon(Icons.refresh, size: 22),
          label: const Text('Coba Lagi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red.shade600,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            elevation: 2,
          ),
        );
    }
  }
}

extension on Color {
  Color get shade700 {
    final hsl = HSLColor.fromColor(this);
    return hsl.withLightness((hsl.lightness - 0.1).clamp(0.0, 1.0)).toColor();
  }
}
