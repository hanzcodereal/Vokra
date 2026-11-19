import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class InfoPage extends StatefulWidget {
  final String sessionKey;

  const InfoPage({super.key, required this.sessionKey});

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> with SingleTickerProviderStateMixin {
  // State Data
  Map<String, dynamic>? serverInfo;
  bool isLoading = true;

  // API Status State
  bool isApiOnline = false;
  int apiPingMs = 0;
  Color apiStatusColor = Colors.grey;
  String apiStatusText = "CHECKING";
  Timer? _pingTimer;
  
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  // Neon Red Theme
  final Color neonRed = const Color(0xFFFF2E63);
  final Color neonRedLight = const Color(0xFFFF6B8A);
  final Color neonRedDark = const Color(0xFFC41E3A);
  final Color bgDark = const Color(0xFF05050A);
  final Color bgCard = const Color(0xFF0A0A14);
  final Color bgSurface = const Color(0xFF11111F);
  final Color textPrimary = const Color(0xFFF3F8FF);
  final Color textMuted = const Color(0xFF8A93B5);

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.9).animate(_glowController);
    
    _fetchServerInfo();
    _startApiPingLoop();
  }

  @override
  void dispose() {
    _pingTimer?.cancel();
    _glowController.dispose();
    super.dispose();
  }

  Future<void> _fetchServerInfo() async {
    try {
      final res = await http.get(
        Uri.parse('$apiBaseUrl/getServerInfo?key=${widget.sessionKey}'),
      );
      if (res.statusCode == 200) {
        setState(() {
          serverInfo = jsonDecode(res.body);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  void _startApiPingLoop() {
    _checkApiPing();
    _pingTimer = Timer.periodic(const Duration(seconds: 5), (_) => _checkApiPing());
  }

  Future<void> _checkApiPing() async {
    final start = DateTime.now();
    try {
      final res = await http.get(
        Uri.parse('$apiBaseUrl/ping?key=${widget.sessionKey}'),
      ).timeout(const Duration(seconds: 3));
      final end = DateTime.now();
      final duration = end.difference(start).inMilliseconds;

      if (res.statusCode == 200) {
        setState(() {
          isApiOnline = true;
          apiPingMs = duration;
          if (duration < 200) {
            apiStatusColor = const Color(0xFF00E5A0);
          } else if (duration < 500) {
            apiStatusColor = const Color(0xFFFFB800);
          } else {
            apiStatusColor = neonRedLight;
          }
          apiStatusText = "ONLINE (${duration}ms)";
        });
      } else {
        throw Exception("Failed");
      }
    } catch (e) {
      setState(() {
        isApiOnline = false;
        apiPingMs = 0;
        apiStatusColor = neonRed;
        apiStatusText = "OFFLINE";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: bgDark,
        appBar: _buildAppBar(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFFFF2E63)),
              const SizedBox(height: 16),
              Text(
                "LOADING SYSTEM DATA",
                style: TextStyle(color: neonRed.withOpacity(0.7), fontSize: 12, fontFamily: 'ShareTechMono'),
              ),
            ],
          ),
        ),
      );
    }

    final List<Map<String, String>> rulesList = [
      {"title": "ACCOUNT TRADING BAN", "desc": "Accounts cannot be traded with goods, services, or other accounts in any form."},
      {"title": "ACCOUNT SHARING BAN", "desc": "Each account is personal and may only be used by the registered owner."},
      {"title": "RESELL RESTRICTION", "desc": "Members are NOT allowed to sell accounts. Only authorized roles may sell."},
      {"title": "ILLEGAL DURATION BAN", "desc": "Selling daily, weekly, trial access outside official terms is prohibited."},
      {"title": "PRICE DUMPING BAN", "desc": "Lowering prices below FIXCH standards (price dumping) is prohibited."},
    ];

    return Scaffold(
      backgroundColor: bgDark,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildApiStatusCard(),
            const SizedBox(height: 24),
            _buildSectionHeader("REGULATIONS"),
            const SizedBox(height: 16),
            ...rulesList.asMap().entries.map((entry) {
              int index = entry.key + 1;
              Map<String, String> rule = entry.value;
              return _buildRuleCard(index, rule['title']!, rule['desc']!);
            }).toList(),
            const SizedBox(height: 24),
            _buildSanctionCard(),
            const SizedBox(height: 24),
            _buildFooter(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: bgSurface,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: neonRed),
        onPressed: () => Navigator.pop(context),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [neonRed, neonRedDark]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.gavel_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            "REGULATION CENTER",
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 14,
              color: neonRed,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApiStatusCard() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [bgCard, bgCard.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: apiStatusColor.withOpacity(0.4 + (0.1 * _glowAnimation.value)),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: apiStatusColor.withOpacity(0.1 * _glowAnimation.value),
                blurRadius: 15,
                spreadRadius: 2,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: apiStatusColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: apiStatusColor.withOpacity(0.6), blurRadius: 8, spreadRadius: 2),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "SYSTEM STATUS",
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 11,
                        color: textMuted,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      apiStatusText,
                      style: TextStyle(
                        fontFamily: 'ShareTechMono',
                        fontSize: 14,
                        color: apiStatusColor,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isApiOnline ? Icons.check_circle_rounded : Icons.error_rounded,
                color: apiStatusColor,
                size: 28,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 24,
          decoration: BoxDecoration(
            color: neonRed,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Orbitron',
            fontSize: 16,
            color: textPrimary,
            letterSpacing: 2,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        Container(
          width: 40,
          height: 1,
          color: neonRed.withOpacity(0.3),
        ),
      ],
    );
  }

  Widget _buildRuleCard(int index, String title, String description) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: bgCard,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: neonRed.withOpacity(0.2 + (0.05 * _glowAnimation.value)),
              width: 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [neonRed.withOpacity(0.15), neonRedDark.withOpacity(0.05)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: neonRed.withOpacity(0.3)),
                ),
                child: Center(
                  child: Text(
                    index.toString(),
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 14,
                      color: neonRed,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 14,
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description,
                      style: TextStyle(
                        fontFamily: 'ShareTechMono',
                        fontSize: 11,
                        color: textMuted,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.gavel_rounded, color: neonRed.withOpacity(0.4), size: 18),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSanctionCard() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [neonRed.withOpacity(0.08), neonRedDark.withOpacity(0.04)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: neonRed.withOpacity(0.4 + (0.1 * _glowAnimation.value)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: neonRed.withOpacity(0.1 * _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 3,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [neonRed, neonRedDark]),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: neonRed.withOpacity(0.4), blurRadius: 15, spreadRadius: 3),
                  ],
                ),
                child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [neonRed, neonRedLight],
                ).createShader(bounds),
                child: Text(
                  "SANCTION",
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "IF A USER IS PROVEN TO VIOLATE ANY REGULATION:",
                style: TextStyle(
                  fontFamily: 'ShareTechMono',
                  fontSize: 12,
                  color: textMuted,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: neonRed.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: neonRed.withOpacity(0.4)),
                ),
                child: Text(
                  "ACCOUNT PERMANENTLY DELETED",
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 14,
                    color: neonRed,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "WITHOUT REFUND, BALANCE RETURN, OR ANY COMPENSATION",
                style: TextStyle(
                  fontFamily: 'ShareTechMono',
                  fontSize: 10,
                  color: neonRedLight,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Divider(color: neonRed.withOpacity(0.2), height: 1),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security_rounded, color: neonRed.withOpacity(0.5), size: 12),
            const SizedBox(width: 6),
            Text(
              "REGULATIONS ENFORCED",
              style: TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 9,
                color: textMuted.withOpacity(0.5),
                letterSpacing: 1,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 4,
              height: 4,
              decoration: BoxDecoration(
                color: neonRed.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 12),
            Icon(Icons.gavel_rounded, color: neonRed.withOpacity(0.5), size: 12),
            const SizedBox(width: 6),
            Text(
              "NO TOLERANCE",
              style: TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 9,
                color: textMuted.withOpacity(0.5),
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "SixEyesX v8.5",
          style: TextStyle(
            fontFamily: 'ShareTechMono',
            fontSize: 8,
            color: textMuted.withOpacity(0.3),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }
}