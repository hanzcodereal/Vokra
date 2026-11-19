import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final AnimationController _neonPulseController;
  late final Animation<double> _neonPulse;
  late final VideoPlayerController _videoController;

  bool _isVideoReady = false;
  bool _isVideoPlaying = false;
  bool _isLocationLoading = true;
  String _locationLabel = 'DETECTING LOCATION';
  String _locationDetail = 'Fetching geolocation data...';
  String? _mapsUrl;

  final Color neonCyan = const Color(0xFF00D4FF);
  final Color neonPink = const Color(0xFFFF2E63);
  final Color neonPurple = const Color(0xFFBD00FF);
  final Color neonGreen = const Color(0xFF00E5A0);
  final Color neonYellow = const Color(0xFFFFB800);
  final Color bgDark = const Color(0xFF05050A);
  final Color bgCard = const Color(0xFF0A0A14);
  final Color bgSurface = const Color(0xFF11111F);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic));

    _neonPulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _neonPulse = Tween<double>(begin: 0.3, end: 0.8).animate(_neonPulseController);

    _videoController = VideoPlayerController.asset('assets/videos/landing.mp4');

    _animationController.forward();
    _initializeVideo();
    _loadLocation();
  }

  Future<void> _initializeVideo() async {
    try {
      await _videoController.initialize();
      await _videoController.setLooping(true);
      await _videoController.setVolume(0);
      await _videoController.play();
      if (!mounted) return;
      setState(() {
        _isVideoReady = true;
        _isVideoPlaying = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isVideoReady = false;
        _isVideoPlaying = false;
      });
    }
  }

  Future<void> _loadLocation() async {
    try {
      final response = await http.get(
        Uri.parse('https://ipapi.co/json/'),
        headers: const {'Accept': 'application/json'},
      );
      if (response.statusCode != 200) throw Exception('Location request failed');
      final data = json.decode(response.body) as Map<String, dynamic>;
      final city = (data['city'] ?? '').toString().trim();
      final region = (data['region'] ?? '').toString().trim();
      final country = (data['country_name'] ?? '').toString().trim();
      final latitude = data['latitude']?.toString();
      final longitude = data['longitude']?.toString();

      final label = [if (city.isNotEmpty) city, if (region.isNotEmpty && region != city) region].join(', ');
      final detail = [if (country.isNotEmpty) country, if ((data['timezone'] ?? '').toString().trim().isNotEmpty) data['timezone'].toString().trim()].join(' • ');

      if (!mounted) return;
      setState(() {
        _locationLabel = label.isNotEmpty ? label.toUpperCase() : 'LOCATION UNKNOWN';
        _locationDetail = detail.isNotEmpty ? detail : 'Geolocation data unavailable';
        _mapsUrl = latitude != null && longitude != null ? 'https://maps.google.com/?q=$latitude,$longitude' : null;
        _isLocationLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _locationLabel = 'LOCATION OFFLINE';
        _locationDetail = 'Check connection and reload';
        _mapsUrl = null;
        _isLocationLoading = false;
      });
    }
  }

  Future<void> _toggleVideoPlayback() async {
    if (!_isVideoReady) return;
    if (_videoController.value.isPlaying) {
      await _videoController.pause();
    } else {
      await _videoController.play();
    }
    if (!mounted) return;
    setState(() {
      _isVideoPlaying = _videoController.value.isPlaying;
    });
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _animationController.dispose();
    _neonPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [bgDark, bgSurface, const Color(0xFF000000)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildNeonHeader(),
                    const SizedBox(height: 24),
                    _buildHeroSection(),
                    const SizedBox(height: 24),
                    _buildInfoPanel(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 20),
                    _buildSocialRow(),
                    const SizedBox(height: 30),
                    _buildFooter(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNeonHeader() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _neonPulse,
          builder: (context, child) {
            return Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [neonPurple, neonPink]),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: neonPink.withOpacity(_neonPulse.value), blurRadius: 30, spreadRadius: 4),
                  BoxShadow(color: neonPurple.withOpacity(_neonPulse.value), blurRadius: 20, spreadRadius: 2),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset('assets/images/logo.png', fit: BoxFit.cover),
              ),
            );
          },
        ),
        const SizedBox(height: 16),
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [neonCyan, neonPink, neonPurple],
          ).createShader(bounds),
          child: const Text(
            'SixEyesX',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Orbitron',
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'NEXUS GATEWAY v8.5',
          style: TextStyle(
            fontSize: 10,
            color: neonCyan.withOpacity(0.7),
            fontFamily: 'ShareTechMono',
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [bgCard, bgCard.withOpacity(0.6)],
        ),
        border: Border.all(color: neonCyan.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(color: neonCyan.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              height: 420,
              child: _isVideoReady
                  ? VideoPlayer(_videoController)
                  : Container(
                      color: bgDark,
                      child: Center(
                        child: Icon(Icons.play_circle_outline_rounded, color: neonCyan, size: 64),
                      ),
                    ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                    bgDark.withOpacity(0.9),
                  ],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: neonPink.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: neonPink.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.fiber_manual_record_rounded, color: neonPink, size: 10),
                            const SizedBox(width: 6),
                            Text(
                              _isVideoPlaying ? 'LIVE STREAMING' : 'PAUSED',
                              style: TextStyle(color: neonPink, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: _isVideoReady ? _toggleVideoPlayback : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: neonCyan.withOpacity(0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_isVideoPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: neonCyan, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            _isVideoPlaying ? 'PAUSE PREVIEW' : 'PLAY PREVIEW',
                            style: TextStyle(color: neonCyan, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonGreen.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(color: neonGreen, borderRadius: BorderRadius.circular(4)),
              ),
              const SizedBox(width: 12),
              Text(
                'GEOLOCATION STATUS',
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 11,
                  color: neonGreen,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.location_on_rounded, color: neonCyan, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _locationLabel,
                      style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _locationDetail,
                      style: TextStyle(color: Colors.white54, fontSize: 10),
                    ),
                  ],
                ),
              ),
              if (_mapsUrl != null)
                GestureDetector(
                  onTap: () => _openUrl(_mapsUrl!),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: neonCyan.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: neonCyan.withOpacity(0.4)),
                    ),
                    child: Icon(Icons.map_rounded, color: neonCyan, size: 18),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildNeonButton(
            label: 'SIGN IN',
            icon: Icons.login_rounded,
            color: neonCyan,
            onTap: () => Navigator.pushNamed(context, '/login'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildNeonButton(
            label: 'BUY ACCESS',
            icon: Icons.shopping_bag_rounded,
            color: neonPink,
            onTap: () => _openUrl('https://t.me/XyanzZz'),
            outline: true,
          ),
        ),
      ],
    );
  }

  Widget _buildNeonButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool outline = false,
  }) {
    return AnimatedBuilder(
      animation: _neonPulse,
      builder: (context, child) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: 54,
            decoration: BoxDecoration(
              gradient: outline ? null : LinearGradient(colors: [color, color.withOpacity(0.6)]),
              color: outline ? Colors.transparent : null,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: color.withOpacity(outline ? 0.6 : 0.3), width: outline ? 1.5 : 0),
              boxShadow: outline ? null : [BoxShadow(color: color.withOpacity(0.4), blurRadius: 15, offset: const Offset(0, 6))],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: outline ? color : Colors.white, size: 20),
                  const SizedBox(width: 10),
                  Text(
                    label,
                    style: TextStyle(
                      color: outline ? color : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                      fontFamily: 'Orbitron',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSocialRow() {
    final List<Map<String, dynamic>> socials = [
      {'icon': FontAwesomeIcons.telegram, 'label': 'TELEGRAM', 'url': 'https://t.me/XyanzZz', 'color': const Color(0xFF0088cc)},
      {'icon': FontAwesomeIcons.whatsapp, 'label': 'WHATSAPP', 'url': 'https://whatsapp.com/channel/0029VbCpAEh9WtCBsdFI8V1X', 'color': const Color(0xFF25D366)},
    ];

    return Row(
      children: socials.map((social) {
        return Expanded(
          child: GestureDetector(
            onTap: () => _openUrl(social['url'] as String),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: bgCard,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: (social['color'] as Color).withOpacity(0.4)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FaIcon(social['icon'] as IconData, color: social['color'] as Color, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    social['label'] as String,
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security_rounded, color: neonGreen, size: 10),
            const SizedBox(width: 4),
            Text('ENCRYPTED', style: TextStyle(color: Colors.white38, fontSize: 8, fontFamily: 'ShareTechMono')),
            const SizedBox(width: 12),
            Icon(Icons.flash_on_rounded, color: neonPink, size: 10),
            const SizedBox(width: 4),
            Text('SECURE NODE', style: TextStyle(color: Colors.white38, fontSize: 8, fontFamily: 'ShareTechMono')),
            const SizedBox(width: 12),
            Icon(Icons.speed_rounded, color: neonCyan, size: 10),
            const SizedBox(width: 4),
            Text('99.9% UPTIME', style: TextStyle(color: Colors.white38, fontSize: 8, fontFamily: 'ShareTechMono')),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'SixEyesX 2026',
          style: TextStyle(color: Colors.white24, fontSize: 8, fontFamily: 'ShareTechMono', letterSpacing: 1),
        ),
      ],
    );
  }
}