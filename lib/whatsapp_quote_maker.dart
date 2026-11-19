import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class WhatsAppQuoteMakerPage extends StatefulWidget {
  const WhatsAppQuoteMakerPage({super.key});

  @override
  State<WhatsAppQuoteMakerPage> createState() => _WhatsAppQuoteMakerPageState();
}

class _WhatsAppQuoteMakerPageState extends State<WhatsAppQuoteMakerPage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _senderController = TextEditingController(
    text: 'WhatsApp',
  );
  final GlobalKey _previewKey = GlobalKey();

  bool _isSaving = false;
  String _previewMessage =
      'Tuliskan kata-kata kamu di sini, lalu simpan jadi gambar WhatsApp.';
  String _previewSender = 'WhatsApp';
  String? _lastSavedPath;

  final Color bgDark = const Color(0xFF030917);
  final Color panel = const Color(0xFF0C1A31);
  final Color panelStrong = const Color(0xFF122544);
  final Color outline = const Color(0xFF2A4F8A);
  final Color accentBlue = const Color(0xFF4DA3FF);
  final Color accentCyan = const Color(0xFF6DC8FF);
  final Color textPrimary = const Color(0xFFF3F8FF);
  final Color textMuted = const Color(0xFF9CB3D1);
  final Color iosGreen = const Color(0xFF25D366);
  final Color iosBubble = const Color(0xFFE7FEDC);
  final Color iosSurface = const Color(0xFFF5F2EA);

  void _applyPreview() {
    final message = _messageController.text.trim();
    final sender = _senderController.text.trim();

    setState(() {
      _previewMessage = message.isEmpty
          ? 'Tuliskan kata-kata kamu di sini, lalu simpan jadi gambar WhatsApp.'
          : message;
      _previewSender = sender.isEmpty ? 'WhatsApp' : sender;
    });
  }

  Future<Uint8List?> _capturePreview() async {
    final boundary =
        _previewKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData?.buffer.asUint8List();
  }

  Future<Directory> _resolveSaveDirectory() async {
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted &&
          await Permission.manageExternalStorage.request().isDenied) {
        throw Exception('Izin penyimpanan ditolak.');
      }

      final downloadDir = Directory('/storage/emulated/0/Download');
      if (await downloadDir.exists()) {
        return downloadDir;
      }

      final extDir = await getExternalStorageDirectory();
      if (extDir != null) {
        return extDir;
      }
    }

    return getApplicationDocumentsDirectory();
  }

  Future<void> _saveImage() async {
    FocusScope.of(context).unfocus();
    _applyPreview();

    setState(() {
      _isSaving = true;
      _lastSavedPath = null;
    });

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final pngBytes = await _capturePreview();
      if (pngBytes == null) {
        throw Exception('Preview belum siap.');
      }

      final directory = await _resolveSaveDirectory();
      final file = File(
        '${directory.path}/wa_quote_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes, flush: true);

      if (!mounted) return;
      setState(() {
        _lastSavedPath = file.path;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: panelStrong,
          content: Text(
            'Gambar berhasil disimpan ke ${file.path}',
            style: TextStyle(color: textPrimary),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Gagal menyimpan gambar: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _shareImage() async {
    FocusScope.of(context).unfocus();
    _applyPreview();

    try {
      await Future.delayed(const Duration(milliseconds: 100));
      final pngBytes = await _capturePreview();
      if (pngBytes == null) {
        throw Exception('Preview belum siap.');
      }

      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/wa_quote_share_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(pngBytes, flush: true);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'WhatsApp Quote Maker',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            'Gagal membagikan gambar: $e',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _senderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'WA QUOTE MAKER',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontFamily: 'Orbitron',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [panelStrong, panel],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: outline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bikin quote screenshot dengan vibe WhatsApp iPhone, lalu simpan jadi PNG.',
                      style: TextStyle(
                        color: textMuted,
                        fontFamily: 'ShareTechMono',
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInput(
                      controller: _senderController,
                      label: 'Nama Pengirim',
                      hint: 'Contoh: DarkVerse, Adit, My Love',
                      maxLines: 1,
                    ),
                    const SizedBox(height: 14),
                    _buildInput(
                      controller: _messageController,
                      label: 'Isi Kata-kata',
                      hint: 'Tulis pesan yang ingin dijadikan chat bubble...',
                      maxLines: 6,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _applyPreview,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('UPDATE PREVIEW'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accentBlue,
                          foregroundColor: bgDark,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Preview',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Orbitron',
                ),
              ),
              const SizedBox(height: 12),
              RepaintBoundary(
                key: _previewKey,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        iosSurface,
                        const Color(0xFFEDE8DE),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(34),
                    border: Border.all(color: Colors.white.withOpacity(0.65)),
                    image: DecorationImage(
                      image: const AssetImage('assets/images/reze.png'),
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withOpacity(0.9),
                        BlendMode.lighten,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 26,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: const [
                          Text(
                            '9:41',
                            style: TextStyle(
                              color: Color(0xFF0F1720),
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          Spacer(),
                          Icon(Icons.signal_cellular_alt, size: 16, color: Color(0xFF0F1720)),
                          SizedBox(width: 4),
                          Icon(Icons.wifi_rounded, size: 15, color: Color(0xFF0F1720)),
                          SizedBox(width: 4),
                          Icon(Icons.battery_full_rounded, size: 18, color: Color(0xFF0F1720)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: Color(0xFF007AFF),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [iosGreen, const Color(0xFF93E56B)],
                              ),
                            ),
                            child: const Icon(
                              Icons.person_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _previewSender,
                                  style: const TextStyle(
                                    color: Color(0xFF0F1720),
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'WhatsApp',
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.45),
                                    fontSize: 12.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.videocam_rounded, color: Color(0xFF007AFF)),
                          const SizedBox(width: 10),
                          const Icon(Icons.call_rounded, color: Color(0xFF007AFF)),
                        ],
                      ),
                      const SizedBox(height: 26),
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          constraints: const BoxConstraints(minHeight: 116, maxWidth: 320),
                          padding: const EdgeInsets.fromLTRB(16, 14, 14, 12),
                          decoration: BoxDecoration(
                            color: iosBubble,
                            borderRadius: BorderRadius.circular(24).copyWith(
                              bottomRight: const Radius.circular(8),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.12),
                                blurRadius: 18,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _previewMessage,
                                style: const TextStyle(
                                  color: Color(0xFF17212B),
                                  fontSize: 18,
                                  height: 1.42,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 14),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text(
                                    '12:45',
                                    style: TextStyle(
                                      color: Colors.black.withOpacity(0.42),
                                      fontSize: 11,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  const Icon(
                                    Icons.done_all_rounded,
                                    size: 16,
                                    color: Color(0xFF34B7F1),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.82),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: Colors.black.withOpacity(0.04)),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.add_circle_outline_rounded, color: iosGreen, size: 22),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'iMessage style, WA soul.',
                                style: TextStyle(
                                  color: Colors.black.withOpacity(0.45),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Icon(Icons.camera_alt_rounded, color: Color(0xFF8796A5), size: 20),
                            const SizedBox(width: 10),
                            const Icon(Icons.mic_none_rounded, color: Color(0xFF8796A5), size: 20),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isSaving ? null : _saveImage,
                      icon: Icon(_isSaving ? Icons.hourglass_top : Icons.download),
                      label: Text(_isSaving ? 'MENYIMPAN...' : 'UNDUH PNG'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentBlue,
                        foregroundColor: bgDark,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _shareImage,
                      icon: const Icon(Icons.share_rounded),
                      label: const Text('SHARE'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: textPrimary,
                        side: BorderSide(color: outline),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ],
              ),
              if (_lastSavedPath != null) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: panelStrong,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: outline),
                  ),
                  child: Text(
                    'Tersimpan di:\n$_lastSavedPath',
                    style: TextStyle(
                      color: textMuted,
                      fontFamily: 'ShareTechMono',
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String label,
    required String hint,
    required int maxLines,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: textMuted),
        hintStyle: TextStyle(color: textMuted.withOpacity(0.6)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.03),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: accentBlue, width: 1.6),
        ),
      ),
      onChanged: (_) => _applyPreview(),
    );
  }
}
