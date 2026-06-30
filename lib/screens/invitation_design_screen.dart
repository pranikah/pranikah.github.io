import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import '../models/invitation.dart';
import '../theme/app_theme.dart';

class InvitationDesignScreen extends StatefulWidget {
  const InvitationDesignScreen({super.key});

  @override
  State<InvitationDesignScreen> createState() => _InvitationDesignScreenState();
}

class _InvitationDesignScreenState extends State<InvitationDesignScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  // RepaintBoundary keys for screenshot capture
  final _coverKey = GlobalKey();
  final _contentKey = GlobalKey();
  final _backKey = GlobalKey();

  // Form controllers
  final _groomNameCtrl = TextEditingController();
  final _brideNameCtrl = TextEditingController();
  final _venueNameCtrl = TextEditingController();
  final _venueAddressCtrl = TextEditingController();
  final _groomParentsCtrl = TextEditingController();
  final _brideParentsCtrl = TextEditingController();
  final _additionalInfoCtrl = TextEditingController();

  DateTime _weddingDate = DateTime.now().add(const Duration(days: 90));
  TimeOfDay _weddingTime = const TimeOfDay(hour: 8, minute: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSaved();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _groomNameCtrl.dispose();
    _brideNameCtrl.dispose();
    _venueNameCtrl.dispose();
    _venueAddressCtrl.dispose();
    _groomParentsCtrl.dispose();
    _brideParentsCtrl.dispose();
    _additionalInfoCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSaved() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('invitation_draft');
    if (json != null) {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final inv = Invitation.fromMap('draft', data);
      setState(() {
        _groomNameCtrl.text = inv.groomName;
        _brideNameCtrl.text = inv.brideName;
        _weddingDate = inv.weddingDate;
        final timeParts = inv.weddingTime.split(':');
        _weddingTime = TimeOfDay(
          hour: int.tryParse(timeParts[0]) ?? 8,
          minute: int.tryParse(timeParts.length > 1 ? timeParts[1] : '0') ?? 0,
        );
        _venueNameCtrl.text = inv.venueName;
        _venueAddressCtrl.text = inv.venueAddress;
        _groomParentsCtrl.text = inv.groomParents;
        _brideParentsCtrl.text = inv.brideParents;
        _additionalInfoCtrl.text = inv.additionalInfo;
      });
    }
  }

  Invitation _buildInvitation() {
    return Invitation(
      id: 'draft',
      groomName: _groomNameCtrl.text.isEmpty ? 'Nama Mempelai Pria' : _groomNameCtrl.text,
      brideName: _brideNameCtrl.text.isEmpty ? 'Nama Mempelai Wanita' : _brideNameCtrl.text,
      weddingDate: _weddingDate,
      weddingTime: '${_weddingTime.hour.toString().padLeft(2, '0')}:${_weddingTime.minute.toString().padLeft(2, '0')}',
      venueName: _venueNameCtrl.text.isEmpty ? 'Nama Gedung' : _venueNameCtrl.text,
      venueAddress: _venueAddressCtrl.text.isEmpty ? 'Alamat Gedung' : _venueAddressCtrl.text,
      groomParents: _groomParentsCtrl.text,
      brideParents: _brideParentsCtrl.text,
      templateId: 'default',
      additionalInfo: _additionalInfoCtrl.text,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _saveInvitation() async {
    final prefs = await SharedPreferences.getInstance();
    final inv = _buildInvitation();
    await prefs.setString('invitation_draft', jsonEncode(inv.toMap()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Undangan berhasil disimpan')),
      );
    }
  }

  Future<void> _downloadPng() async {
    GlobalKey activeKey;
    switch (_tabController.index) {
      case 0:
        activeKey = _coverKey;
        break;
      case 1:
        activeKey = _contentKey;
        break;
      default:
        activeKey = _backKey;
    }

    try {
      final boundary = activeKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showError('Gagal mengambil gambar');
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showError('Gagal konversi gambar');
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();

      if (kIsWeb) {
        _downloadBytesWeb(pngBytes, 'undangan_${_tabController.index}.png');
      } else {
        _showError('Fitur download untuk mobile segera hadir');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  void _downloadBytesWeb(Uint8List bytes, String fileName) {
    // Web download using universal_html or js interop
    // For now show success message - actual download needs dart:html on web
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('PNG siap: $fileName (${bytes.length} bytes)')),
    );
  }

  void _downloadPdf() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('PDF coming soon - fitur sedang dikembangkan')),
    );
  }

  void _showError(String msg) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _weddingDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _weddingDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _weddingTime,
    );
    if (picked != null) setState(() => _weddingTime = picked);
  }

  @override
  Widget build(BuildContext context) {
    // ignore: unused_local_variable
    final loc = AppLocalizations.of(context)!;
    final inv = _buildInvitation();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Undangan'),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildForm(),
                  const SizedBox(height: 24),
                  _buildTabSection(inv),
                ],
              ),
            ),
          ),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data Undangan',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField(_groomNameCtrl, 'Nama Mempelai Pria', Icons.person),
              const SizedBox(height: 12),
              _buildTextField(_brideNameCtrl, 'Nama Mempelai Wanita', Icons.person_outline),
              const SizedBox(height: 12),
              _buildDateTimeRow(),
              const SizedBox(height: 12),
              _buildTextField(_venueNameCtrl, 'Nama Gedung / Tempat', Icons.location_city),
              const SizedBox(height: 12),
              _buildTextField(_venueAddressCtrl, 'Alamat Lengkap', Icons.location_on),
              const SizedBox(height: 12),
              _buildTextField(_groomParentsCtrl, 'Orang Tua Pria (Bapak & Ibu)', Icons.family_restroom),
              const SizedBox(height: 12),
              _buildTextField(_brideParentsCtrl, 'Orang Tua Wanita (Bapak & Ibu)', Icons.family_restroom),
              const SizedBox(height: 12),
              _buildTextField(_additionalInfoCtrl, 'Informasi Tambahan', Icons.info_outline, maxLines: 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String label, IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.primary),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDateTimeRow() {
    final dateStr = DateFormat('dd MMMM yyyy', 'id').format(_weddingDate);
    final timeStr = _weddingTime.format(context);

    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Tanggal',
                prefixIcon: Icon(Icons.calendar_today, color: AppTheme.primary),
              ),
              child: Text(dateStr),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: InkWell(
            onTap: _pickTime,
            child: InputDecorator(
              decoration: const InputDecoration(
                labelText: 'Waktu',
                prefixIcon: Icon(Icons.access_time, color: AppTheme.primary),
              ),
              child: Text(timeStr),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabSection(Invitation inv) {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppTheme.secondary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: _tabController,
            onTap: (_) => setState(() {}),
            labelColor: AppTheme.primaryDark,
            unselectedLabelColor: AppTheme.textLight,
            indicatorColor: AppTheme.primary,
            tabs: const [
              Tab(text: 'Cover'),
              Tab(text: 'Isi'),
              Tab(text: 'Belakang'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 500,
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildCoverPreview(inv),
              _buildContentPreview(inv),
              _buildBackPreview(inv),
            ],
          ),
        ),
      ],
    );
  }

  // ─── COVER PREVIEW ───────────────────────────────────────────────────────
  Widget _buildCoverPreview(Invitation inv) {
    final dateStr = DateFormat('dd MMMM yyyy', 'id').format(inv.weddingDate);
    return RepaintBoundary(
      key: _coverKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // Decorative corner borders
            Positioned(top: 12, left: 12, child: _cornerDecor(true, true)),
            Positioned(top: 12, right: 12, child: _cornerDecor(true, false)),
            Positioned(bottom: 12, left: 12, child: _cornerDecor(false, true)),
            Positioned(bottom: 12, right: 12, child: _cornerDecor(false, false)),
            // Content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'The Wedding of',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 14,
                        color: AppTheme.textLight,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      inv.groomName,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '&',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 28,
                        color: AppTheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      inv.brideName,
                      style: const TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryDark,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: 60,
                      height: 1,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      dateStr,
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: 14,
                        color: AppTheme.textLight,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cornerDecor(bool isTop, bool isLeft) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _CornerPainter(
          isTop: isTop,
          isLeft: isLeft,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  // ─── CONTENT (ISI) PREVIEW ────────────────────────────────────────────────
  Widget _buildContentPreview(Invitation inv) {
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id').format(inv.weddingDate);
    final timeStr = inv.weddingTime;

    return RepaintBoundary(
      key: _contentKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.primaryDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Dengan memohon rahmat dan ridho Allah SWT,\nkami bermaksud menyelenggarakan pernikahan putra-putri kami:',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 11,
                  color: AppTheme.textLight,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (inv.groomParents.isNotEmpty)
                Text(
                  'Putra dari ${inv.groomParents}',
                  style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                  textAlign: TextAlign.center,
                ),
              Text(
                inv.groomName,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'dengan',
                style: TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                  color: AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                inv.brideName,
                style: const TextStyle(
                  fontFamily: 'Georgia',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryDark,
                ),
                textAlign: TextAlign.center,
              ),
              if (inv.brideParents.isNotEmpty)
                Text(
                  'Putri dari ${inv.brideParents}',
                  style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 20),
              Container(width: 40, height: 1, color: AppTheme.primary),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    dateStr,
                    style: const TextStyle(fontFamily: 'Georgia', fontSize: 12, color: AppTheme.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.access_time, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Text(
                    'Pukul $timeStr WIB',
                    style: const TextStyle(fontFamily: 'Georgia', fontSize: 12, color: AppTheme.textDark),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.location_on, size: 14, color: AppTheme.primary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      '${inv.venueName}\n${inv.venueAddress}',
                      style: const TextStyle(fontFamily: 'Georgia', fontSize: 12, color: AppTheme.textDark),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
              if (inv.additionalInfo.isNotEmpty) ...[
                const SizedBox(height: 16),
                Text(
                  inv.additionalInfo,
                  style: TextStyle(fontSize: 11, color: AppTheme.textLight, fontStyle: FontStyle.italic),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── BACK (BELAKANG) PREVIEW ──────────────────────────────────────────────
  Widget _buildBackPreview(Invitation inv) {
    return RepaintBoundary(
      key: _backKey,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite,
                  size: 48,
                  color: AppTheme.primary.withValues(alpha: 0.6),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Terima Kasih',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryDark,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Merupakan suatu kebahagiaan dan kehormatan\nbagi kami apabila Bapak/Ibu/Saudara/i\nberkenan hadir di acara pernikahan kami.',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 12,
                    color: AppTheme.textLight,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(width: 40, height: 1, color: AppTheme.primary),
                const SizedBox(height: 24),
                Text(
                  'Hormat kami,',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 12,
                    color: AppTheme.textLight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${inv.groomName} & ${inv.brideName}',
                  style: const TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryDark,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                // Simple decorative element instead of QR
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primary.withValues(alpha: 0.4), width: 1.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.qr_code_2,
                    size: 36,
                    color: AppTheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _downloadPng,
              icon: const Icon(Icons.image),
              label: const Text('PNG'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primary,
                side: const BorderSide(color: AppTheme.primary),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _downloadPdf,
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('PDF'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryDark,
                side: const BorderSide(color: AppTheme.primaryDark),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _saveInvitation,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



// ─── Custom Painter for decorative corners ────────────────────────────────
class _CornerPainter extends CustomPainter {
  final bool isTop;
  final bool isLeft;
  final Color color;

  _CornerPainter({required this.isTop, required this.isLeft, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    if (isTop && isLeft) {
      path.moveTo(0, size.height);
      path.lineTo(0, 0);
      path.lineTo(size.width, 0);
    } else if (isTop && !isLeft) {
      path.moveTo(0, 0);
      path.lineTo(size.width, 0);
      path.lineTo(size.width, size.height);
    } else if (!isTop && isLeft) {
      path.moveTo(0, 0);
      path.lineTo(0, size.height);
      path.lineTo(size.width, size.height);
    } else {
      path.moveTo(0, size.height);
      path.lineTo(size.width, size.height);
      path.lineTo(size.width, 0);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
