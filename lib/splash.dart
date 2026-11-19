import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'dashboard_page.dart';

class SplashScreen extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final String telegramId;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const SplashScreen({
    super.key,
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.sessionKey,
    required this.telegramId,
    required this.listBug,
    required this.listDoos,
    required this.news,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoController;
  AnimationController? _fadeController;
  Timer? _timeoutTimer;
  bool _fadeOutStarted = false;
  bool _initFailed = false;
  bool _hasNavigated = false;
  String _debugInfo = '';

  // --- Speed Control ---
  double _playbackSpeed = 1.0;
  List<double> speedOptions = [0.5, 1.0, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _initializeSplash();
  }

  void _initializeSplash() async {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    try {
      final controller = VideoPlayerController.asset(
        "assets/videos/splash.mp4",
      );
      _videoController = controller;

      await controller.initialize();
      if (!mounted) return;

      setState(() {
        _debugInfo = 'Video initialized: ${controller.value.size}';
      });

      await controller.setLooping(false);
      await controller.setPlaybackSpeed(_playbackSpeed);
      await controller.play();

      // Video listener
      controller.addListener(_videoListener);

      // Safety timeout: navigate after max 5 seconds
      _timeoutTimer = Timer(const Duration(seconds: 5), _navigateToDashboard);
    } catch (e) {
      debugPrint('Splash video init FAILED: $e');
      if (!mounted) return;
      setState(() {
        _initFailed = true;
        _debugInfo = 'Video failed: $e';
      });
      // Immediate fallback timeout
      _timeoutTimer = Timer(const Duration(seconds: 2), _navigateToDashboard);
    }
  }

  void _videoListener() {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;

    debugPrint('Video pos: $position / duration: $duration');

    if (duration != const Duration(seconds: 0) &&
        position >= duration - const Duration(seconds: 1) &&
        !_fadeOutStarted) {
      _fadeOutStarted = true;
      _fadeController?.forward();
    }

    if (position >= duration) {
      _navigateToDashboard();
    }
  }

  void _navigateToDashboard() {
    _timeoutTimer?.cancel();
    if (_hasNavigated) return;
    _hasNavigated = true;
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => DashboardPage(
            username: widget.username,
            password: widget.password,
            role: widget.role,
            expiredDate: widget.expiredDate,
            sessionKey: widget.sessionKey,
            telegramId: widget.telegramId,
            listBug: widget.listBug,
            listDoos: widget.listDoos,
            news: widget.news,
          ),
        ),
      );
    }
  }

  Future<void> _changePlaybackSpeed(double speed) async {
    final controller = _videoController;
    if (controller == null || !controller.value.isInitialized) return;

    await controller.setPlaybackSpeed(speed);
    if (!mounted) return;
    setState(() {
      _playbackSpeed = speed;
    });
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _fadeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoController = _videoController;
    final fadeController = _fadeController;
    final isVideoReady =
        videoController != null &&
        videoController.value.isInitialized &&
        !_initFailed;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // VIDEO BACKGROUND
          if (isVideoReady)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: videoController.value.size.width,
                  height: videoController.value.size.height,
                  child: VideoPlayer(videoController),
                ),
              ),
            )
          else
            // FALLBACK: Logo + Spinner + Text
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.purpleAccent, width: 3),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/logo.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(color: Colors.purpleAccent),
                  const SizedBox(height: 20),
                  const Text(
                    'Loading Immortal...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

          // TEKS "DarkVerse"
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: const Text(
                "SixEyesX",
                style: TextStyle(
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 3,
                  shadows: [
                    Shadow(
                      color: Colors.purpleAccent,
                      blurRadius: 15,
                      offset: Offset(2, 2),
                    ),
                    Shadow(
                      color: Colors.black,
                      blurRadius: 15,
                      offset: Offset(-2, -2),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // SPEED CONTROL (only if video ok)
          if (isVideoReady)
            Positioned(
              top: 40,
              right: 20,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.purpleAccent.withValues(alpha: 0.6),
                    width: 2,
                  ),
                ),
                child: PopupMenuButton<double>(
                  icon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.speed,
                          color: Colors.purpleAccent,
                          size: 22,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_playbackSpeed}x',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  color: const Color(0xFF1A1A1A),
                  itemBuilder: (context) => speedOptions
                      .map<PopupMenuItem<double>>(
                        (speed) => PopupMenuItem<double>(
                          value: speed,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${speed}x',
                                  style: TextStyle(
                                    color: _playbackSpeed == speed
                                        ? Colors.purpleAccent
                                        : Colors.white70,
                                    fontWeight: _playbackSpeed == speed
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    fontSize: 15,
                                  ),
                                ),
                                if (_playbackSpeed == speed) ...[
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.check,
                                    color: Colors.purpleAccent,
                                    size: 18,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      )
                      .toList(),
                  onSelected: _changePlaybackSpeed,
                ),
              ),
            ),

          // DEBUG INFO (remove in production)
          if (_debugInfo.isNotEmpty)
            Positioned(
              top: 100,
              left: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: Colors.black54,
                child: Text(
                  _debugInfo,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

          // FADE OUT OVERLAY
          if (_fadeOutStarted && fadeController != null)
            FadeTransition(
              opacity: fadeController.drive(Tween(begin: 1.0, end: 0.0)),
              child: Container(color: Colors.black),
            ),
        ],
      ),
    );
  }
}
