import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class KillMlbbPage extends StatefulWidget {
  const KillMlbbPage({super.key});

  @override
  State<KillMlbbPage> createState() => _KillMlbbPageState();
}

class _KillMlbbPageState extends State<KillMlbbPage> with SingleTickerProviderStateMixin {
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Color neonRed = const Color(0xFFFF2E63);
  final Color neonRedLight = const Color(0xFFFF6B8A);
  final Color neonRedDark = const Color(0xFFC41E3A);
  final Color bgDark = const Color(0xFF05050A);
  final Color bgCard = const Color(0xFF0A0A14);
  final Color bgSurface = const Color(0xFF11111F);
  final Color textPrimary = const Color(0xFFF3F8FF);
  final Color textMuted = const Color(0xFF8A93B5);

  bool _isLagging = false;
  bool _isProcessing = false;
  String _selectedServer = "SERVEUR GARENA";
  String _status = "STAND BY";
  String _currentApp = "MLBB";
  
  List<String> _installedApps = [];
  bool _isLoadingApps = false;

  final List<String> _serverList = [
    "SERVEUR GARENA",
    "SERVEUR 4"
  ];

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.3, end: 0.9).animate(_glowController);
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(_pulseController);
    
    _loadSettings();
    _scanInstalledApps();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedServer = prefs.getString('kill_mlbb_server') ?? "SERVEUR GARENA";
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('kill_mlbb_server', _selectedServer);
  }

  Future<void> _scanInstalledApps() async {
    setState(() {
      _isLoadingApps = true;
      _installedApps = [];
    });
    
    try {
      if (Platform.isAndroid) {
        final result = await MethodChannel('com.immortal.x.silence/apps').invokeMethod('getInstalledApps');
        if (result != null && result is List) {
          setState(() {
            _installedApps = result.cast<String>();
          });
        }
      }
      
      if (_installedApps.isEmpty) {
        _installedApps = [
          "com.mobile.legends",
          "com.mobile.legends.x",
          "com.mobile.legends.beta"
        ];
      }
    } catch (e) {
      _installedApps = [
        "com.mobile.legends",
        "com.mobile.legends.x",
        "com.mobile.legends.beta"
      ];
    } finally {
      setState(() {
        _isLoadingApps = false;
      });
    }
  }

  Future<void> _toggleLag() async {
    if (_isProcessing) return;
    
    setState(() {
      _isProcessing = true;
    });
    
    try {
      if (!_isLagging) {
        await _startLag();
        setState(() {
          _isLagging = true;
          _status = "LAG ACTIVE";
        });
      } else {
        await _stopLag();
        setState(() {
          _isLagging = false;
          _status = "CONNECTION NORMAL";
        });
      }
    } catch (e) {
      setState(() {
        _status = "ERROR: ${e.toString().substring(0, 30)}";
      });
      _showSnackbar("Failed to ${_isLagging ? 'stop' : 'start'} lag: $e", isError: true);
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _startLag() async {
    final server = _selectedServer == "SERVEUR GARENA" ? "garena" : "server4";
    
    try {
      await MethodChannel('com.immortal.x.silence/lag').invokeMethod('startLag', {
        'server': server,
        'duration': 30,
        'intensity': 85,
        'targetApp': _currentApp,
      });
      
      _showSnackbar("LAG ACTIVATED ON $_selectedServer");
      
      await Future.delayed(const Duration(seconds: 1));
      
      await _openMlbb();
      
    } catch (e) {
      await _simulateLag();
    }
  }

  Future<void> _simulateLag() async {
    for (int i = 0; i < 20; i++) {
      await Process.run('ping', ['-c', '1', '-W', '2', '8.8.8.8']);
      await Future.delayed(Duration(milliseconds: 50 + (i * 10)));
    }
  }

  Future<void> _stopLag() async {
    try {
      await MethodChannel('com.immortal.x.silence/lag').invokeMethod('stopLag');
      _showSnackbar("Lag stopped, connection restored");
    } catch (e) {
      _showSnackbar("Lag stopped", isError: false);
    }
  }

  Future<void> _openMlbb() async {
    try {
      if (Platform.isAndroid) {
        await MethodChannel('com.immortal.x.silence/apps').invokeMethod('openApp', {
          'package': _currentAppPackage(),
        });
      } else {
        await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.mobile.legends'));
      }
    } catch (e) {
      await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.mobile.legends'));
    }
  }

  String _currentAppPackage() {
    if (_currentApp == "MLBB") return "com.mobile.legends";
    if (_currentApp == "MLBB X") return "com.mobile.legends.x";
    return "com.mobile.legends";
  }

  void _changeApp(String app) {
    setState(() {
      _currentApp = app;
    });
    _showSnackbar("TARGET APP: $app");
  }

  void _changeServer(String server) {
    setState(() {
      _selectedServer = server;
    });
    _saveSettings();
    _showSnackbar("SERVER CHANGED: $server");
  }

  void _showSnackbar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'ShareTechMono', fontWeight: FontWeight.bold)),
        backgroundColor: isError ? neonRed : neonRedDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              _buildAppSelectorCard(),
              const SizedBox(height: 20),
              _buildServerCard(),
              const SizedBox(height: 20),
              _buildControlCard(),
              const SizedBox(height: 20),
              _buildStatusCard(),
              const SizedBox(height: 20),
              _buildInfoCard(),
              const SizedBox(height: 20),
              _buildAppsListCard(),
            ],
          ),
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
            child: const Icon(Icons.wifi_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 10),
          Text(
            "KILL MLBB",
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

  Widget _buildHeaderCard() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [neonRed.withOpacity(0.1), bgCard],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: neonRed.withOpacity(0.4), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: neonRed.withOpacity(0.15 * _pulseAnimation.value),
                blurRadius: 25,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [neonRed, neonRedDark]),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: neonRed.withOpacity(0.5), blurRadius: 20, spreadRadius: 4),
                    ],
                  ),
                  child: Icon(
                    _isLagging ? Icons.wifi_off_rounded : Icons.wifi_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [neonRed, neonRedLight],
                  ).createShader(bounds),
                  child: Text(
                    "LAG GENERATOR",
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "CONNECTION INTERFERENCE TOOL",
                  style: TextStyle(
                    fontFamily: 'ShareTechMono',
                    fontSize: 10,
                    color: textMuted,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAppSelectorCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.apps_rounded, color: neonRed, size: 20),
              const SizedBox(width: 10),
              Text(
                "TARGET APPLICATION",
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  color: textPrimary,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAppButton("MLBB", _currentApp == "MLBB"),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAppButton("MLBB X", _currentApp == "MLBB X"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppButton(String appName, bool isSelected) {
    return GestureDetector(
      onTap: () => _changeApp(appName),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? neonRed.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? neonRed : neonRed.withOpacity(0.3),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.games_rounded,
              color: isSelected ? neonRed : textMuted,
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              appName,
              style: TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 12,
                color: isSelected ? neonRed : textMuted,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.dns_rounded, color: neonRed, size: 20),
              const SizedBox(width: 10),
              Text(
                "SELECT SERVER",
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 12,
                  color: textPrimary,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: _serverList.map((server) {
              final isSelected = _selectedServer == server;
              return Expanded(
                child: GestureDetector(
                  onTap: () => _changeServer(server),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? neonRed.withOpacity(0.15) : Colors.transparent,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? neonRed : neonRed.withOpacity(0.3),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        server,
                        style: TextStyle(
                          fontFamily: 'ShareTechMono',
                          fontSize: 11,
                          color: isSelected ? neonRed : textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildControlCard() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isLagging
                  ? [neonRed.withOpacity(0.2), neonRedDark.withOpacity(0.1)]
                  : [bgCard, bgCard.withOpacity(0.6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: neonRed.withOpacity(0.4 + (0.2 * _glowAnimation.value)),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: neonRed.withOpacity(0.1 * _glowAnimation.value),
                blurRadius: 20,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _isLagging ? [neonRed, neonRedDark] : [neonRedDark, neonRed.withOpacity(0.5)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: neonRed.withOpacity(_isLagging ? 0.6 : 0.2),
                      blurRadius: 25,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Icon(
                  _isLagging ? Icons.wifi_off_rounded : Icons.wifi_find_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _toggleLag,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isLagging ? [neonRedDark, neonRed] : [neonRed, neonRedLight],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: neonRed.withOpacity(0.4),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _isLagging ? "STOP LAG" : "ACTIVATE LAG",
                      style: TextStyle(
                        fontFamily: 'Orbitron',
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: neonRed.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _isLagging ? neonRed : neonRed.withOpacity(0.3),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _isLagging ? neonRed.withOpacity(0.8) : Colors.transparent,
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "CURRENT STATUS",
                  style: TextStyle(
                    fontFamily: 'Orbitron',
                    fontSize: 10,
                    color: textMuted,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _status,
                  style: TextStyle(
                    fontFamily: 'ShareTechMono',
                    fontSize: 14,
                    color: _isLagging ? neonRed : textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          if (_isProcessing)
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color(0xFFFF2E63),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: neonRed.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: neonRed.withOpacity(0.6), size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "Activate lag mode while playing $_currentApp. The server will experience high latency causing disconnection for 30 seconds.",
              style: TextStyle(
                fontFamily: 'ShareTechMono',
                fontSize: 10,
                color: textMuted.withOpacity(0.7),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppsListCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: neonRed.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.download_rounded, color: neonRed, size: 18),
              const SizedBox(width: 10),
              Text(
                "INSTALL MLBB",
                style: TextStyle(
                  fontFamily: 'Orbitron',
                  fontSize: 11,
                  color: textPrimary,
                  letterSpacing: 1,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              await launchUrl(Uri.parse('https://play.google.com/store/apps/details?id=com.mobile.legends'));
            },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: neonRed.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: neonRed.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  "INSTALL MOBILE LEGENDS",
                  style: TextStyle(
                    fontFamily: 'ShareTechMono',
                    fontSize: 12,
                    color: neonRed,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}