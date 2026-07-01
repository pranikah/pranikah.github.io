import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:ui' as ui;
import 'dart:convert';
import 'dart:typed_data';
import 'package:pra_nikah_app/l10n/app_localizations.dart';
import '../models/invitation.dart';
import '../providers/wedding_provider.dart';
import '../theme/app_theme.dart';

// Background decoration options
enum BgDecoration {
  none,
  bungaSakura,
  bungaMawar,
  bungaMelati,
  daunTropis,
  rumahJoglo,
  rumahGadang,
  ornamenIslami,
  batik,
  mandala,
  geometris,
  bintang,
}

extension BgDecorationExt on BgDecoration {
  String get label {
    switch (this) {
      case BgDecoration.none: return 'Polos';
      case BgDecoration.bungaSakura: return 'Bunga Sakura';
      case BgDecoration.bungaMawar: return 'Bunga Mawar';
      case BgDecoration.bungaMelati: return 'Bunga Melati';
      case BgDecoration.daunTropis: return 'Daun Tropis';
      case BgDecoration.rumahJoglo: return 'Rumah Joglo';
      case BgDecoration.rumahGadang: return 'Rumah Gadang';
      case BgDecoration.ornamenIslami: return 'Ornamen Islami';
      case BgDecoration.batik: return 'Batik';
      case BgDecoration.mandala: return 'Mandala';
      case BgDecoration.geometris: return 'Geometris';
      case BgDecoration.bintang: return 'Bintang';
    }
  }

  String get icon {
    switch (this) {
      case BgDecoration.none: return '⬜';
      case BgDecoration.bungaSakura: return '🌸';
      case BgDecoration.bungaMawar: return '🌹';
      case BgDecoration.bungaMelati: return '🤍';
      case BgDecoration.daunTropis: return '🌿';
      case BgDecoration.rumahJoglo: return '🏛️';
      case BgDecoration.rumahGadang: return '🏠';
      case BgDecoration.ornamenIslami: return '🕌';
      case BgDecoration.batik: return '🎭';
      case BgDecoration.mandala: return '☸️';
      case BgDecoration.geometris: return '💎';
      case BgDecoration.bintang: return '✨';
    }
  }
}

class InvitationDesignScreen extends StatefulWidget {
  const InvitationDesignScreen({super.key});

  @override
  State<InvitationDesignScreen> createState() => _InvitationDesignScreenState();
}

class _InvitationDesignScreenState extends State<InvitationDesignScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _previewKey = GlobalKey();

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

  // Design state
  Color _bgColor = Colors.white;
  Color _textColor = const Color(0xFF333333);
  BgDecoration _bgDecoration = BgDecoration.none;

  // Color palette options
  static const List<Color> _bgColorOptions = [
    Colors.white,
    Color(0xFFFFF8E1),
    Color(0xFFFCE4EC),
    Color(0xFFE8F5E9),
    Color(0xFFE3F2FD),
    Color(0xFFF3E5F5),
    Color(0xFF1A1A2E),
    Color(0xFF2C3E50),
    Color(0xFF4A0E2E),
  ];

  static const List<Color> _textColorOptions = [
    Color(0xFF333333),
    Color(0xFF880E4F),
    Color(0xFF4A148C),
    Color(0xFF1B5E20),
    Color(0xFF0D47A1),
    Color(0xFFB8860B),
    Colors.white,
    Color(0xFFF5F5DC),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadSaved();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadFromPlan());
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
    // Load design prefs
    final bgColorVal = prefs.getInt('inv_bgColor');
    final textColorVal = prefs.getInt('inv_textColor');
    final bgDecIdx = prefs.getInt('inv_bgDecoration');
    if (bgColorVal != null) _bgColor = Color(bgColorVal);
    if (textColorVal != null) _textColor = Color(textColorVal);
    if (bgDecIdx != null && bgDecIdx < BgDecoration.values.length) {
      _bgDecoration = BgDecoration.values[bgDecIdx];
    }
    setState(() {});
  }

  void _loadFromPlan() {
    final provider = context.read<WeddingProvider>();
    final plan = provider.plan;
    if (plan != null) {
      if (_groomNameCtrl.text.isEmpty && plan.groomName.isNotEmpty) {
        _groomNameCtrl.text = plan.groomName;
      }
      if (_brideNameCtrl.text.isEmpty && plan.brideName.isNotEmpty) {
        _brideNameCtrl.text = plan.brideName;
      }
      if (_groomNameCtrl.text.isEmpty || _brideNameCtrl.text.isEmpty) {
        setState(() => _weddingDate = plan.weddingDate);
      }
    }
  }

  Future<void> _saveAll() async {
    final prefs = await SharedPreferences.getInstance();
    // Save invitation data
    final inv = Invitation(
      id: 'draft',
      groomName: _groomNameCtrl.text.isEmpty ? '' : _groomNameCtrl.text,
      brideName: _brideNameCtrl.text.isEmpty ? '' : _brideNameCtrl.text,
      weddingDate: _weddingDate,
      weddingTime: '${_weddingTime.hour.toString().padLeft(2, '0')}:${_weddingTime.minute.toString().padLeft(2, '0')}',
      venueName: _venueNameCtrl.text,
      venueAddress: _venueAddressCtrl.text,
      groomParents: _groomParentsCtrl.text,
      brideParents: _brideParentsCtrl.text,
      templateId: 'custom',
      additionalInfo: _additionalInfoCtrl.text,
      createdAt: DateTime.now(),
    );
    await prefs.setString('invitation_draft', jsonEncode(inv.toMap()));
    // Save design prefs
    await prefs.setInt('inv_bgColor', _bgColor.toARGB32());
    await prefs.setInt('inv_textColor', _textColor.toARGB32());
    await prefs.setInt('inv_bgDecoration', _bgDecoration.index);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Undangan berhasil disimpan!')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Design Undangan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: 'Simpan',
            onPressed: _saveAll,
          ),
        ],
      ),
      body: Column(
        children: [
          // Tab bar
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: AppTheme.textLight,
              indicator: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: const [
                Tab(text: '📝 Input Data'),
                Tab(text: '🎨 Design'),
                Tab(text: '👁️ Preview'),
              ],
            ),
          ),
          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInputTab(),
                _buildDesignTab(),
                _buildPreviewTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }


  // ─── TAB 1: INPUT DATA ──────────────────────────────────────────────────
  Widget _buildInputTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          _buildTextField(_groomParentsCtrl, 'Orang Tua Pria', Icons.family_restroom),
          const SizedBox(height: 12),
          _buildTextField(_brideParentsCtrl, 'Orang Tua Wanita', Icons.family_restroom),
          const SizedBox(height: 12),
          _buildTextField(_additionalInfoCtrl, 'Pesan / Doa (Opsional)', Icons.message, maxLines: 3),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(1),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Lanjut ke Design →'),
          ),
        ],
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
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
        ),
      ),
      onChanged: (_) => setState(() {}),
    );
  }

  Widget _buildDateTimeRow() {
    final dateStr = DateFormat('dd MMM yyyy', 'id').format(_weddingDate);
    final timeStr = _weddingTime.format(context);
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: _pickDate,
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: 'Tanggal',
                prefixIcon: const Icon(Icons.calendar_today, color: AppTheme.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              decoration: InputDecoration(
                labelText: 'Waktu',
                prefixIcon: const Icon(Icons.access_time, color: AppTheme.primary),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(timeStr),
            ),
          ),
        ),
      ],
    );
  }


  // ─── TAB 2: DESIGN ──────────────────────────────────────────────────────
  Widget _buildDesignTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Background color
          const Text('🎨 Warna Background', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _bgColorOptions.map((color) {
              final isSelected = _bgColor.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _bgColor = color),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 8)]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 20, color: _isDark(color) ? Colors.white : Colors.black)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Text color
          const Text('✏️ Warna Teks', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _textColorOptions.map((color) {
              final isSelected = _textColor.toARGB32() == color.toARGB32();
              return GestureDetector(
                onTap: () => setState(() => _textColor = color),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                      width: isSelected ? 3 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.3), blurRadius: 8)]
                        : null,
                  ),
                  child: isSelected
                      ? Icon(Icons.check, size: 20, color: _isDark(color) ? Colors.white : Colors.black)
                      : null,
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // Background decoration
          const Text('🖼️ Background Hiasan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 0.85,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: BgDecoration.values.length,
            itemBuilder: (context, index) {
              final dec = BgDecoration.values[index];
              final isSelected = _bgDecoration == dec;
              return GestureDetector(
                onTap: () => setState(() => _bgDecoration = dec),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? AppTheme.primary : Colors.grey.shade200,
                      width: isSelected ? 2.5 : 1,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.2), blurRadius: 8)]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(dec.icon, style: const TextStyle(fontSize: 28)),
                      const SizedBox(height: 6),
                      Text(
                        dec.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          color: isSelected ? AppTheme.primary : AppTheme.textLight,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _tabController.animateTo(2),
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Lihat Preview →'),
          ),
        ],
      ),
    );
  }

  bool _isDark(Color color) {
    return ThemeData.estimateBrightnessForColor(color) == Brightness.dark;
  }


  // ─── TAB 3: PREVIEW ─────────────────────────────────────────────────────
  Widget _buildPreviewTab() {
    final groom = _groomNameCtrl.text.isEmpty ? 'Nama Mempelai Pria' : _groomNameCtrl.text;
    final bride = _brideNameCtrl.text.isEmpty ? 'Nama Mempelai Wanita' : _brideNameCtrl.text;
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id').format(_weddingDate);
    final timeStr = '${_weddingTime.hour.toString().padLeft(2, '0')}:${_weddingTime.minute.toString().padLeft(2, '0')}';
    final venue = _venueNameCtrl.text.isEmpty ? 'Nama Gedung' : _venueNameCtrl.text;
    final address = _venueAddressCtrl.text.isEmpty ? 'Alamat Lengkap' : _venueAddressCtrl.text;
    final message = _additionalInfoCtrl.text;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Preview card
          RepaintBoundary(
            key: _previewKey,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 500),
              decoration: BoxDecoration(
                color: _bgColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  // Background decoration layer
                  if (_bgDecoration != BgDecoration.none)
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.12,
                        child: Center(
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            alignment: WrapAlignment.center,
                            children: List.generate(20, (_) =>
                              Text(_bgDecoration.icon, style: const TextStyle(fontSize: 28)),
                            ),
                          ),
                        ),
                      ),
                    ),
                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                    child: Column(
                      children: [
                        Text(
                          'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيم',
                          style: TextStyle(fontSize: 14, color: _textColor.withValues(alpha: 0.7)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Dengan memohon rahmat Allah SWT\nkami mengundang Bapak/Ibu/Saudara/i',
                          style: TextStyle(fontSize: 12, color: _textColor.withValues(alpha: 0.6), height: 1.5),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          groom,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '&',
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                            color: _textColor.withValues(alpha: 0.6),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          bride,
                          style: TextStyle(
                            fontFamily: 'Georgia',
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: _textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        Container(width: 50, height: 1.5, color: _textColor.withValues(alpha: 0.3)),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: _textColor.withValues(alpha: 0.6)),
                            const SizedBox(width: 8),
                            Text(dateStr, style: TextStyle(fontSize: 13, color: _textColor)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.access_time, size: 14, color: _textColor.withValues(alpha: 0.6)),
                            const SizedBox(width: 8),
                            Text('Pukul $timeStr WIB', style: TextStyle(fontSize: 13, color: _textColor)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.location_on, size: 14, color: _textColor.withValues(alpha: 0.6)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                '$venue\n$address',
                                style: TextStyle(fontSize: 13, color: _textColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                        if (message.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            message,
                            style: TextStyle(
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                              color: _textColor.withValues(alpha: 0.7),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _downloadPng,
                  icon: const Icon(Icons.image),
                  label: const Text('Download PNG'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primary,
                    side: const BorderSide(color: AppTheme.primary),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _saveAll,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _downloadPng() async {
    try {
      final boundary = _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        _showMsg('Gagal mengambil gambar', isError: true);
        return;
      }
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        _showMsg('Gagal konversi gambar', isError: true);
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();
      if (kIsWeb) {
        _showMsg('PNG siap: undangan.png (${pngBytes.length} bytes)');
      } else {
        _showMsg('Fitur download untuk mobile segera hadir');
      }
    } catch (e) {
      _showMsg('Error: $e', isError: true);
    }
  }

  void _showMsg(String msg, {bool isError = false}) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(msg),
          backgroundColor: isError ? Colors.red : null,
        ),
      );
    }
  }
}
