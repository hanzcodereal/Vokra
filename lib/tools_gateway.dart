import 'dart:math';
import 'package:flutter/material.dart';

import 'anime.dart';
import 'ddos_panel.dart';
import 'device_tools_page.dart';
import 'domain_page.dart';
import 'game_page.dart';
import 'manage_server.dart';
import 'nik_check.dart';
import 'report_telegram.dart';
import 'spam_ngl.dart';
import 'whatsapp_quote_maker.dart';
import 'logo_maker.dart';
import 'notification_channel_page.dart';
import 'tqto_page.dart';
import 'about_developer_page.dart';
import 'kil_mlbb_page.dart';
import 'marketing_page.dart';

class ToolsPage extends StatelessWidget {
  final String sessionKey;
  final String userRole;
  final List<Map<String, dynamic>> listDoos;

  const ToolsPage({
    super.key,
    required this.sessionKey,
    required this.userRole,
    required this.listDoos,
  });

  final Color neonRed = const Color(0xFFFF2E63);
  final Color neonRedLight = const Color(0xFFFF6B8A);
  final Color neonRedDark = const Color(0xFFC41E3A);
  final Color bgDark = const Color(0xFF05050A);
  final Color bgSurface = const Color(0xFF0A0A14);
  final Color textPrimary = const Color(0xFFF3F8FF);
  final Color textMuted = const Color(0xFF8A93B5);

  List<_ToolEntry> _toolEntries(BuildContext context) {
    return [
      _ToolEntry(
        title: 'NIK Check',
        subtitle: 'ID Validator',
        icon: Icons.badge_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NikCheckerPage()),
        ),
      ),
      _ToolEntry(
        title: 'Subdomain',
        subtitle: 'Domain Finder',
        icon: Icons.dns_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DomainOsintPage()),
        ),
      ),
      _ToolEntry(
        title: 'Channel',
        subtitle: 'Chat Channel',
        icon: Icons.telegram,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NotificationChannelPage()),
        ),
      ),
      _ToolEntry(
        title: 'Server Hub',
        subtitle: 'Node Manager',
        icon: Icons.storage_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ManageServerPage(keyToken: sessionKey),
          ),
        ),
      ),
      _ToolEntry(
        title: 'Tq To',
        subtitle: 'Thanks To',
        icon: Icons.people_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TqtoPage()),
        ),
      ),
      _ToolEntry(
        title: 'Developer',
        subtitle: 'About Developer',
        icon: Icons.developer_mode_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutDeveloperPage()),
        ),
      ),
      _ToolEntry(
        title: 'Anime',
        subtitle: 'Streaming',
        icon: Icons.movie_filter_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HomeAnimePage()),
        ),
      ),
      _ToolEntry(
        title: 'Kill OTP',
        subtitle: 'Spam OTP',
        icon: Icons.sms_failed_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const NglPage()),
        ),
      ),
      _ToolEntry(
        title: 'Market',
        subtitle: 'Marketing',
        icon: Icons.storefront_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MarketingPage(
              sessionKey: sessionKey,
              role: userRole,
            ),
          ),
        ),
      ),
      _ToolEntry(
        title: 'Telegram Report',
        subtitle: 'Spam Account',
        icon: Icons.telegram,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReportTelegramPage(sessionKey: sessionKey, userRole: userRole),
          ),
        ),
      ),
      _ToolEntry(
        title: 'WA Quote',
        subtitle: 'Text To Image',
        icon: Icons.image_outlined,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const WhatsAppQuoteMakerPage()),
        ),
      ),
      _ToolEntry(
        title: 'Kill Mlbb',
        subtitle: 'Lag Server Mlbb',
        icon: Icons.sports_esports_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KillMlbbPage()),
        ),
      ),
      _ToolEntry(
        title: 'DDoS Center',
        subtitle: 'Attack Panel',
        icon: Icons.flash_on_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AttackPanel(sessionKey: sessionKey, listDoos: listDoos),
          ),
        ),
      ),
      _ToolEntry(
        title: 'Device Tools',
        subtitle: 'Torch & Wallpaper',
        icon: Icons.phone_android_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const DeviceToolsPage()),
        ),
      ),
      _ToolEntry(
        title: 'AI Logo',
        subtitle: 'Prompt to Logo',
        icon: Icons.auto_awesome,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LogoMakerPage()),
        ),
      ),
      _ToolEntry(
        title: 'Neon Game',
        subtitle: 'Tap Rush Arcade',
        icon: Icons.sports_esports_rounded,
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GamePage()),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tools = _toolEntries(context);

    return Container(
      color: bgDark,
      child: SafeArea(
        top: false,
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(tools.length),
              const SizedBox(height: 24),
              _buildSniperGrid(tools, context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(int toolCount) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 4,
          height: 38,
          decoration: BoxDecoration(
            color: neonRed,
            borderRadius: BorderRadius.circular(999),
            boxShadow: [BoxShadow(color: neonRed.withOpacity(0.5), blurRadius: 8)],
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [neonRed, neonRedLight],
                ).createShader(bounds),
                child: Text(
                  "TARGET SNIPER",
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Orbitron',
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$toolCount ACTIVE TARGETS  •  ${userRole.toUpperCase()} ACCESS",
                style: TextStyle(
                  color: neonRed.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'ShareTechMono',
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSniperGrid(List<_ToolEntry> tools, BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tools.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final tool = tools[index];
        return _SniperTargetCard(
          tool: tool,
          index: index,
          neonRed: neonRed,
          neonRedLight: neonRedLight,
          neonRedDark: neonRedDark,
          bgSurface: bgSurface,
          textPrimary: textPrimary,
          textMuted: textMuted,
        );
      },
    );
  }
}

class _SniperTargetCard extends StatefulWidget {
  final _ToolEntry tool;
  final int index;
  final Color neonRed;
  final Color neonRedLight;
  final Color neonRedDark;
  final Color bgSurface;
  final Color textPrimary;
  final Color textMuted;

  const _SniperTargetCard({
    required this.tool,
    required this.index,
    required this.neonRed,
    required this.neonRedLight,
    required this.neonRedDark,
    required this.bgSurface,
    required this.textPrimary,
    required this.textMuted,
  });

  @override
  State<_SniperTargetCard> createState() => _SniperTargetCardState();
}

class _SniperTargetCardState extends State<_SniperTargetCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;
  late Animation<double> _rotateAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    )..repeat();
    _rotateAnimation = Tween<double>(begin: 0, end: 2 * pi).animate(_rotateController);

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(_pulseController);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(_glowController);
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: GestureDetector(
            onTap: widget.tool.onTap,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                gradient: LinearGradient(
                  colors: [
                    widget.neonRed.withOpacity(0.08),
                    widget.bgSurface.withOpacity(0.95),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: widget.neonRed.withOpacity(0.4 + (0.2 * _glowAnimation.value)),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: widget.neonRed.withOpacity(0.15 * _glowAnimation.value),
                    blurRadius: 20,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SniperRingPainter(
                        animation: _rotateAnimation.value,
                        color: widget.neonRed.withOpacity(0.15),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _glowAnimation,
                          builder: (context, child) {
                            return Container(
                              width: 65,
                              height: 65,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    widget.neonRed.withOpacity(0.2 + (0.1 * _glowAnimation.value)),
                                    widget.neonRedDark.withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: widget.neonRed.withOpacity(0.5 + (0.2 * _glowAnimation.value)),
                                  width: 1.2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: widget.neonRed.withOpacity(0.2 * _glowAnimation.value),
                                    blurRadius: 15,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Icon(
                                  widget.tool.icon,
                                  color: widget.neonRed,
                                  size: 32,
                                ),
                              ),
                            );
                          },
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.my_location_rounded, color: widget.neonRed, size: 14),
                            const SizedBox(width: 8),
                            Text(
                              "TARGET ACQUIRED",
                              style: TextStyle(
                                fontFamily: 'ShareTechMono',
                                fontSize: 9,
                                color: widget.neonRed.withOpacity(0.7),
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.tool.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Orbitron',
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.tool.subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.textMuted,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'ShareTechMono',
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: widget.neonRed.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: widget.neonRed.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "ENGAGE",
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: widget.neonRed,
                                  letterSpacing: 1,
                                  fontFamily: 'Orbitron',
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(Icons.arrow_forward_rounded, color: widget.neonRed, size: 12),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: widget.neonRed.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: widget.neonRed.withOpacity(0.4)),
                      ),
                      child: const Icon(Icons.gps_fixed_rounded, color: Color(0xFFFF2E63), size: 14),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        border: Border.all(color: widget.neonRed.withOpacity(0.4), width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Center(
                        child: Icon(Icons.lens_rounded, color: Color(0xFFFF2E63), size: 6),
                      ),
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
}

class _SniperRingPainter extends CustomPainter {
  final double animation;
  final Color color;

  _SniperRingPainter({required this.animation, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2.5;

    for (int i = 0; i < 3; i++) {
      final angle = animation + (i * 2 * pi / 3);
      final x = center.dx + radius * 0.6 * cos(angle);
      final y = center.dy + radius * 0.6 * sin(angle);
      canvas.drawCircle(Offset(x, y), 4, paint);
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.5),
      0,
      2 * pi,
      false,
      paint..strokeWidth = 0.8,
    );

    for (int i = 0; i < 4; i++) {
      final angle = (i * pi / 2) + animation * 0.5;
      final x1 = center.dx + radius * 0.7 * cos(angle);
      final y1 = center.dy + radius * 0.7 * sin(angle);
      final x2 = center.dx + radius * 0.9 * cos(angle);
      final y2 = center.dy + radius * 0.9 * sin(angle);
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SniperRingPainter oldDelegate) {
    return oldDelegate.animation != animation || oldDelegate.color != color;
  }
}

class _ToolEntry {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  const _ToolEntry({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });
}