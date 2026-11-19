import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class LogoMakerPage extends StatefulWidget {
  const LogoMakerPage({super.key});

  @override
  State<LogoMakerPage> createState() => _LogoMakerPageState();
}

class _LogoMakerPageState extends State<LogoMakerPage> {
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _promptController = TextEditingController();

  Uint8List? _generatedImage;
  bool _isGenerating = false;
  String _status = 'Isi nama brand dan prompt untuk mulai generate logo.';
  String _selectedStyle = 'Cyber';

  final Color bgDark = const Color(0xFF07111F);
  final Color panel = const Color(0xFF102238);
  final Color panelStrong = const Color(0xFF162B45);
  final Color outline = const Color(0xFF34547A);
  final Color accent = const Color(0xFF6EE7F9);
  final Color accentSoft = const Color(0xFF38BDF8);
  final Color accentWarm = const Color(0xFFFFB85C);
  final Color textPrimary = const Color(0xFFF5FAFF);
  final Color textMuted = const Color(0xFF9DB3CF);

  static const String _hfApiUrl =
      'https://api-inference.huggingface.co/models/stabilityai/stable-diffusion-xl-base-1.0';

  final List<String> _styles = const [
    'Cyber',
    'Minimal',
    'Esports',
    'Luxury',
    'Mascot',
  ];

  String _buildPrompt() {
    final brand = _brandController.text.trim();
    final prompt = _promptController.text.trim();

    final stylePrompt = switch (_selectedStyle) {
      'Minimal' =>
        'minimal flat logo, clean geometry, white background, premium branding',
      'Esports' =>
        'esports gaming logo, bold mascot emblem, sharp lines, energetic composition',
      'Luxury' =>
        'luxury monogram logo, elegant gold accents, refined composition, premium branding',
      'Mascot' =>
        'mascot logo illustration, clean vector, bold silhouette, brand friendly',
      _ =>
        'cyber futuristic logo, neon accents, sharp vector style, high contrast',
    };

    return [
      if (brand.isNotEmpty) 'brand name "$brand"',
      if (prompt.isNotEmpty) prompt,
      stylePrompt,
      'professional logo mark, centered composition, no watermark, no extra text, clean vector feeling',
    ].join(', ');
  }

  Future<void> _generateLogo() async {
    final prompt = _promptController.text.trim();
    final brand = _brandController.text.trim();

    if (prompt.length < 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Prompt minimal 5 karakter')),
      );
      return;
    }

    setState(() {
      _isGenerating = true;
      _status = 'AI sedang meracik logo untuk ${brand.isEmpty ? "brand kamu" : brand}...';
    });

    try {
      final response = await http.post(
        Uri.parse(_hfApiUrl),
        headers: {
          'User-Agent': 'DarkVerse/1.0',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'inputs': _buildPrompt(),
          'parameters': {
            'width': 768,
            'height': 768,
            'num_inference_steps': 28,
            'guidance_scale': 7.5,
          },
        }),
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final decoded = img.decodeImage(bytes);
        if (decoded == null) {
          throw Exception('Invalid image data');
        }

        final encoded = img.encodePng(decoded);
        setState(() {
          _generatedImage = Uint8List.fromList(encoded);
          _status = 'Logo berhasil dibuat. Kalau belum pas, ubah prompt lalu generate lagi.';
        });
      } else if (response.statusCode == 503) {
        setState(() {
          _status = 'Model lagi sibuk. Coba ulang beberapa saat lagi.';
        });
      } else {
        throw Exception('API error ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _status = 'Generate gagal: $e';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Generate gagal: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isGenerating = false;
        });
      }
    }
  }

  Future<void> _downloadLogo() async {
    if (_generatedImage == null) return;

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/generated_logo_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(_generatedImage!);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Logo hasil generate dari DarkVerse',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
    }
  }

  @override
  void dispose() {
    _brandController.dispose();
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        backgroundColor: bgDark,
        elevation: 0,
        title: Text(
          'AI Logo Maker',
          style: TextStyle(
            color: textPrimary,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: accent.withOpacity(0.2)),
                  gradient: LinearGradient(
                    colors: [
                      panelStrong,
                      panel,
                      Colors.black.withOpacity(0.92),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bikin logo yang lebih proper',
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        fontFamily: 'Orbitron',
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Masukkan nama brand, pilih gaya visual, lalu tulis arahan singkat seperti ikon, warna, suasana, dan karakter brand yang kamu mau.',
                      style: TextStyle(
                        color: textMuted,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        _buildInfoChip(
                          icon: Icons.bolt_rounded,
                          label: 'Fast concept',
                          color: accentSoft,
                        ),
                        _buildInfoChip(
                          icon: Icons.draw_rounded,
                          label: 'Clean prompt',
                          color: accentWarm,
                        ),
                        _buildInfoChip(
                          icon: Icons.layers_rounded,
                          label: 'Style preset',
                          color: accent,
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _buildInput(
                      controller: _brandController,
                      label: 'Nama brand',
                      hint: 'Contoh: ZSNZ Studio',
                      icon: Icons.business_center_outlined,
                    ),
                    const SizedBox(height: 14),
                    _buildInput(
                      controller: _promptController,
                      label: 'Prompt logo',
                      hint: 'Contoh: emblem naga biru, clean, tajam, premium, futuristic',
                      icon: Icons.auto_awesome_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Pilih style',
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _styles.map((style) {
                        final active = _selectedStyle == style;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedStyle = style),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? accent.withOpacity(0.18)
                                  : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                color: active
                                    ? accentSoft.withOpacity(0.85)
                                    : outline.withOpacity(0.7),
                              ),
                            ),
                            child: Text(
                              style,
                              style: TextStyle(
                                color: active ? textPrimary : textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.04),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: outline.withOpacity(0.7)),
                      ),
                      child: Text(
                        'Contoh prompt: wolf monogram, silver chrome, sharp emblem, premium, black background, futuristic',
                        style: TextStyle(
                          color: textMuted,
                          height: 1.45,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isGenerating ? null : _generateLogo,
                        icon: _isGenerating
                            ? SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: bgDark,
                                ),
                              )
                            : const FaIcon(
                                FontAwesomeIcons.wandMagicSparkles,
                                size: 16,
                              ),
                        label: Text(
                          _isGenerating ? 'Generating...' : 'Generate Logo',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: accent,
                          foregroundColor: bgDark,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [panel.withOpacity(0.98), panelStrong.withOpacity(0.92)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(color: outline.withOpacity(0.75)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        color: textMuted,
                        height: 1.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Container(
                      height: 320,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24),
                        gradient: LinearGradient(
                          colors: [
                            Colors.white.withOpacity(0.08),
                            Colors.black.withOpacity(0.28),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        border: Border.all(color: accent.withOpacity(0.14)),
                      ),
                      child: _generatedImage == null
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_search_rounded,
                                    color: textMuted.withOpacity(0.8),
                                    size: 42,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Preview logo akan muncul di sini',
                                    style: TextStyle(
                                      color: textMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Kalau hasil belum pas, tweak prompt dan generate lagi.',
                                    style: TextStyle(
                                      color: textMuted.withOpacity(0.8),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Padding(
                              padding: const EdgeInsets.all(14),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Container(
                                  color: Colors.white,
                                  child: Image.memory(
                                    _generatedImage!,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _generatedImage == null ? null : _downloadLogo,
                        icon: const Icon(Icons.download_rounded),
                        label: const Text('Download / Share'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textPrimary,
                          side: BorderSide(color: accentSoft.withOpacity(0.5)),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: TextStyle(color: textPrimary),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: TextStyle(color: textMuted),
        hintStyle: TextStyle(color: textMuted.withOpacity(0.72)),
        prefixIcon: Icon(icon, color: accent),
        filled: true,
        fillColor: Colors.black.withOpacity(0.22),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: outline.withOpacity(0.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: accentSoft, width: 1.3),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
