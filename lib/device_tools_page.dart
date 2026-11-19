import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:torch_light/torch_light.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

class DeviceToolsPage extends StatefulWidget {
  const DeviceToolsPage({super.key});

  @override
  State<DeviceToolsPage> createState() => _DeviceToolsPageState();
}

class _DeviceToolsPageState extends State<DeviceToolsPage> {
  final Color bg = const Color(0xFF07111F);
  final Color panel = const Color(0xFF102238);
  final Color panelSoft = const Color(0xFF16314F);
  final Color outline = const Color(0xFF2A4F8A);
  final Color accent = const Color(0xFF4DA3FF);
  final Color accentSoft = const Color(0xFF7DD3FC);
  final Color textPrimary = const Color(0xFFF3F8FF);
  final Color textMuted = const Color(0xFF9CB3D1);

  final ImagePicker _picker = ImagePicker();
  final WallpaperManagerFlutter _wallpaperManager = WallpaperManagerFlutter();

  bool _isTorchOn = false;
  bool _isTorchLoading = false;
  bool _isWallpaperLoading = false;
  File? _selectedWallpaper;
  String _status = 'Ready to control your device tools.';

  Future<void> _toggleTorch() async {
    if (_isTorchLoading) return;
    setState(() => _isTorchLoading = true);

    try {
      final available = await TorchLight.isTorchAvailable();
      if (!available) {
        throw Exception('Torch is not available on this device');
      }

      if (_isTorchOn) {
        await TorchLight.disableTorch();
      } else {
        await TorchLight.enableTorch();
      }

      if (!mounted) return;
      setState(() {
        _isTorchOn = !_isTorchOn;
        _status = _isTorchOn
            ? 'Flashlight enabled successfully.'
            : 'Flashlight turned off.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Torch error: $e';
      });
      _snack('Torch error: $e', err: true);
    } finally {
      if (mounted) {
        setState(() => _isTorchLoading = false);
      }
    }
  }

  Future<void> _pickWallpaper() async {
    try {
      final picked = await _picker.pickImage(source: ImageSource.gallery);
      if (picked == null || !mounted) return;
      setState(() {
        _selectedWallpaper = File(picked.path);
        _status = 'Wallpaper image selected. Choose where to apply it.';
      });
    } catch (e) {
      _snack('Failed to pick image: $e', err: true);
    }
  }

  Future<void> _setWallpaper(int location, String label) async {
    if (_isWallpaperLoading) return;
    if (!Platform.isAndroid) {
      _snack('Wallpaper setting only works on Android.', err: true);
      return;
    }
    if (_selectedWallpaper == null) {
      _snack('Pick an image first.', err: true);
      return;
    }

    setState(() => _isWallpaperLoading = true);
    try {
      final success = await _wallpaperManager.setWallpaper(
        _selectedWallpaper!,
        location,
      );

      if (!mounted) return;
      setState(() {
        _status = success
            ? 'Wallpaper applied to $label.'
            : 'Failed to apply wallpaper to $label.';
      });
      _snack(
        success
            ? 'Wallpaper applied to $label.'
            : 'Failed to apply wallpaper to $label.',
        err: !success,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = 'Wallpaper error: $e';
      });
      _snack('Wallpaper error: $e', err: true);
    } finally {
      if (mounted) {
        setState(() => _isWallpaperLoading = false);
      }
    }
  }

  void _snack(String message, {bool err = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: err ? Colors.redAccent : panelSoft,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          'Device Tools',
          style: TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.w800,
            fontFamily: 'Orbitron',
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 18),
              _buildTorchCard(),
              const SizedBox(height: 18),
              _buildWallpaperCard(),
              const SizedBox(height: 18),
              _buildStatusCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [panelSoft, panel, Colors.black.withValues(alpha: 0.92)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accent.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: LinearGradient(
                colors: [accent, accentSoft],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: const Icon(Icons.phone_android_rounded, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phone Controls',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Nyalakan senter dan atur wallpaper HP langsung dari app.',
                  style: TextStyle(color: textMuted, height: 1.45),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTorchCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Flashlight',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isTorchOn ? 'Torch is currently on.' : 'Torch is currently off.',
            style: TextStyle(color: textMuted),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTorchLoading ? null : _toggleTorch,
              icon: Icon(
                _isTorchLoading
                    ? Icons.hourglass_top_rounded
                    : _isTorchOn
                        ? Icons.flash_off_rounded
                        : Icons.flashlight_on_rounded,
              ),
              label: Text(_isTorchOn ? 'Turn Off Flashlight' : 'Turn On Flashlight'),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWallpaperCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wallpaper Setter',
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            Platform.isAndroid
                ? 'Pilih gambar lalu pasang ke home screen, lock screen, atau dua-duanya.'
                : 'Fitur wallpaper hanya tersedia di Android.',
            style: TextStyle(color: textMuted, height: 1.45),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: _pickWallpaper,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: panelSoft,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: accent.withValues(alpha: 0.18)),
              ),
              child: _selectedWallpaper == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wallpaper_rounded, color: accentSoft, size: 40),
                        const SizedBox(height: 10),
                        Text(
                          'Tap to pick wallpaper image',
                          style: TextStyle(
                            color: textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.file(_selectedWallpaper!, fit: BoxFit.cover),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _pickWallpaper,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: textPrimary,
                    side: BorderSide(color: outline),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Pick Image'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isWallpaperLoading
                      ? null
                      : () => _setWallpaper(
                            WallpaperManagerFlutter.homeScreen,
                            'home screen',
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Home'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isWallpaperLoading
                      ? null
                      : () => _setWallpaper(
                            WallpaperManagerFlutter.lockScreen,
                            'lock screen',
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Lock'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: _isWallpaperLoading
                      ? null
                      : () => _setWallpaper(
                            WallpaperManagerFlutter.bothScreens,
                            'both screens',
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Both'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: panelSoft,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: outline),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: accentSoft),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _status,
              style: TextStyle(color: textPrimary, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }
}
