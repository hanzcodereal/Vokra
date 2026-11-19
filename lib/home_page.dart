import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'api_config.dart';
import 'maintenance_notification.dart';

class HomePage extends StatefulWidget {
  final String username;
  final String password;
  final String sessionKey;
  final List<Map<String, dynamic>> listBug;
  final String role;
  final String expiredDate;

  const HomePage({
    super.key,
    required this.username,
    required this.password,
    required this.sessionKey,
    required this.listBug,
    required this.role,
    required this.expiredDate,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final targetController = TextEditingController();
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late AnimationController _welcomeTextController;
  late Animation<double> _welcomeFadeAnimation;
  late Animation<Offset> _welcomeSlideAnimation;
  
  String selectedBugId = "";
  bool _showWelcome = true;

  // Mode Target
  String _selectedBugMode = "number";

  bool _isSending = false;
  String? _responseMessage;

  String _selectedSenderType = "private";
  List<String> activeSenders = [];
  bool _isLoadingSenders = false;
  String? _senderError;

  // Neon Red Theme
  final Color primaryBg = const Color(0xFF0A0A0F);
  final Color cardBg = const Color(0xFF1A1A2E);
  final Color neonRed = const Color(0xFFFF2E63);
  final Color neonRedLight = const Color(0xFFFF6B8A);
  final Color neonRedDark = const Color(0xFFC41E3A);
  final Color textWhite = Colors.white;
  final Color textGrey = Colors.grey.shade400;

  final LinearGradient neonGradient = const LinearGradient(
    colors: [Color(0xFFFF2E63), Color(0xFFFF6B8A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  late VideoPlayerController _videoController;
  late ChewieController _chewieController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _welcomeTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    
    _welcomeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _welcomeTextController, curve: Curves.easeOut),
    );
    
    _welcomeSlideAnimation = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _welcomeTextController, curve: Curves.easeOutCubic),
    );
    
    _welcomeTextController.forward();

    if (widget.listBug.isNotEmpty) {
      selectedBugId = widget.listBug[0]['bug_id'];
    }

    _initializeVideoPlayer();
    _fetchActiveSenders();
    
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _showWelcome = false;
        });
      }
    });
  }

  void _initializeVideoPlayer() {
    _videoController = VideoPlayerController.asset('assets/videos/landing.mp4');
    _videoController.initialize().then((_) {
      setState(() {
        _videoController.setVolume(0);
        _chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: true,
          showControls: false,
          autoInitialize: true,
        );
        _isVideoInitialized = true;
      });
    }).catchError((error) {
      setState(() {
        _isVideoInitialized = false;
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _welcomeTextController.dispose();
    targetController.dispose();
    _videoController.dispose();
    _chewieController.dispose();
    super.dispose();
  }

  String? formatPhoneNumber(String input) {
    final cleaned = input.replaceAll(RegExp(r'[^\d+]'), '');
    if (!cleaned.startsWith('+') || cleaned.length < 8) return null;
    return cleaned;
  }

  bool isValidGroupLink(String input) {
    return input.contains('chat.whatsapp.com') && input.contains('https://');
  }

  String _formatWaitTime(dynamic waitValue) {
    final seconds = int.tryParse('${waitValue ?? ''}') ?? 0;
    if (seconds <= 0) return 'beberapa saat';
    if (seconds >= 3600) {
      final hours = seconds ~/ 3600;
      final minutes = (seconds % 3600) ~/ 60;
      return minutes > 0 ? '$hours jam $minutes menit' : '$hours jam';
    }
    if (seconds >= 60) {
      final minutes = seconds ~/ 60;
      final remainingSeconds = seconds % 60;
      return remainingSeconds > 0 ? '$minutes menit $remainingSeconds detik' : '$minutes menit';
    }
    return '$seconds detik';
  }

  void _applySenderPayload(Map<String, dynamic> data) {
    final globalConnections = data["globalConnections"] as List<dynamic>? ?? [];
    activeSenders = globalConnections
        .whereType<Map>()
        .map((item) => item["sessionName"]?.toString() ?? item["id"]?.toString() ?? "Unknown")
        .toList();
  }

  Future<void> _sendBug() async {
    final rawInput = targetController.text.trim();
    final key = widget.sessionKey;

    if (_selectedBugMode == "number") {
      final target = formatPhoneNumber(rawInput);
      if (target == null || key.isEmpty) {
        _showAlert("INVALID NUMBER", "Use international format (ex: +62, +1), not 08xxx.");
        return;
      }
    } else {
      if (!isValidGroupLink(rawInput)) {
        _showAlert("INVALID LINK", "Enter valid WhatsApp group link (https://chat.whatsapp.com/...).");
        return;
      }
    }

    if (_selectedSenderType == "global" && activeSenders.isEmpty) {
      await _fetchActiveSenders();
      if (activeSenders.isEmpty) {
        _showAlert("NO GLOBAL SENDER", "No active global sender available.");
        return;
      }
    }

    setState(() {
      _isSending = true;
      _responseMessage = null;
    });

    try {
      final res = await http.get(
        Uri.parse("$apiBaseUrl/sendBug?key=$key&target=$rawInput&bug=$selectedBugId&senderType=$_selectedSenderType"),
      );
      final data = jsonDecode(res.body) as Map<String, dynamic>;

      if (data["cooldown"] == true) {
        final message = data["message"]?.toString();
        final waitText = _formatWaitTime(data["wait"]);
        setState(() => _responseMessage = message?.isNotEmpty == true ? "COOLDOWN: $message" : "COOLDOWN: Wait $waitText.");
      } else if (data["valid"] == false) {
        setState(() => _responseMessage = "INVALID KEY: Please login again.");
      } else if (data["sended"] == false) {
        setState(() => _responseMessage = "FAILED: ${data["message"] ?? "Failed to send bug."}");
      } else {
        final senderLabel = _selectedSenderType == "global" ? "global sender" : "private sender";
        setState(() => _responseMessage = "SUCCESS: Bug sent with $senderLabel!");
        targetController.clear();
      }
    } catch (_) {
      setState(() => _responseMessage = "ERROR: Connection failed. Try again.");
    } finally {
      setState(() => _isSending = false);
      if (_selectedSenderType == "global") {
        _fetchActiveSenders();
      }
    }
  }

  Future<void> _fetchActiveSenders() async {
    setState(() {
      _isLoadingSenders = true;
      _senderError = null;
    });

    try {
      final res = await http.get(Uri.parse("$apiBaseUrl/mySender?key=${widget.sessionKey}"));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        if (data["valid"] == true) {
          setState(() => _applySenderPayload(data));
        } else {
          setState(() {
            _senderError = data["message"] ?? "Failed to load senders";
            activeSenders = [];
          });
        }
      } else {
        setState(() {
          _senderError = "Server error: ${res.statusCode}";
          activeSenders = [];
        });
      }
    } catch (e) {
      setState(() {
        _senderError = "Connection failed: $e";
        activeSenders = [];
      });
    } finally {
      setState(() => _isLoadingSenders = false);
    }
  }

  void _toggleBugSelection(String bugId) {
    setState(() {
      if (selectedBugId == bugId) {
        selectedBugId = "";
      } else {
        selectedBugId = bugId;
      }
    });
  }

  void _showAlert(String title, String msg) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: neonRed.withOpacity(0.5)),
        ),
        title: Text(title, style: const TextStyle(color: Color(0xFFFF2E63), fontFamily: 'Orbitron', fontWeight: FontWeight.bold)),
        content: Text(msg, style: const TextStyle(color: Colors.grey, fontFamily: 'ShareTechMono')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Color(0xFFFF2E63), fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeOverlay() {
    if (!_showWelcome) return const SizedBox.shrink();
    
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(0.85),
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_welcomeFadeAnimation, _welcomeSlideAnimation]),
            builder: (context, child) {
              return Opacity(
                opacity: _welcomeFadeAnimation.value,
                child: Transform.translate(
                  offset: _welcomeSlideAnimation.value,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          gradient: neonGradient,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: neonRed.withOpacity(0.6), blurRadius: 30, spreadRadius: 5),
                          ],
                        ),
                        child: const Icon(Icons.flash_on_rounded, color: Colors.white, size: 50),
                      ),
                      const SizedBox(height: 30),
                      ShaderMask(
                        shaderCallback: (bounds) => neonGradient.createShader(bounds),
                        child: const Text(
                          "SixEyesX",
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Orbitron', letterSpacing: 2),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "WELCOME TO BUG MENU",
                        style: TextStyle(fontSize: 18, color: neonRedLight, fontFamily: 'Orbitron', letterSpacing: 3),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: 200,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: neonGradient,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 30),
                      GestureDetector(
                        onTap: () => setState(() => _showWelcome = false),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: neonRed.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(30),
                            border: Border.all(color: neonRed.withOpacity(0.5)),
                          ),
                          child: const Text(
                            "SKIP",
                            style: TextStyle(color: Color(0xFFFF2E63), fontFamily: 'Orbitron', fontWeight: FontWeight.bold, letterSpacing: 2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildSenderTypeSelector() {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: neonRed.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "SELECT SENDER",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Orbitron', letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _selectedSenderType = "private"),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedSenderType == "private" ? neonRed.withOpacity(0.2) : Colors.white10,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _selectedSenderType == "private" ? neonRed : Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.person, color: _selectedSenderType == "private" ? neonRed : Colors.white60, size: 28),
                        const SizedBox(height: 10),
                        Text("PRIVATE", style: TextStyle(color: _selectedSenderType == "private" ? Colors.white : Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text("Use own session", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text("10 min cooldown", textAlign: TextAlign.center, style: TextStyle(color: neonRed, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() => _selectedSenderType = "global");
                    if (activeSenders.isEmpty) _fetchActiveSenders();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedSenderType == "global" ? neonRed.withOpacity(0.18) : Colors.white10,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: _selectedSenderType == "global" ? neonRed : Colors.white12),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.public, color: _selectedSenderType == "global" ? neonRed : Colors.white60, size: 28),
                        const SizedBox(height: 10),
                        Text("GLOBAL", style: TextStyle(color: _selectedSenderType == "global" ? Colors.white : Colors.white70, fontWeight: FontWeight.bold, fontSize: 16)),
                        const SizedBox(height: 6),
                        Text("Use active senders", textAlign: TextAlign.center, style: TextStyle(color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 6),
                        Text("1 hour cooldown", textAlign: TextAlign.center, style: TextStyle(color: neonRed, fontSize: 11)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: neonRed.withOpacity(0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedSenderType == "global" ? "Active global senders" : "Using private sender",
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (_selectedSenderType == "global")
                      IconButton(
                        onPressed: _fetchActiveSenders,
                        icon: Icon(Icons.refresh, color: Colors.white70, size: 20),
                        tooltip: "Refresh list",
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                if (_selectedSenderType == "global") ...[
                  if (_isLoadingSenders)
                    const Center(child: CircularProgressIndicator(color: Color(0xFFFF2E63)))
                  else if (_senderError != null)
                    Text(_senderError!, style: const TextStyle(color: Colors.redAccent, fontSize: 13))
                  else if (activeSenders.isEmpty)
                    const Text("No active global senders.", style: TextStyle(color: Colors.white70, fontSize: 13))
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: activeSenders.map((sender) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: neonRed, size: 16),
                            const SizedBox(width: 8),
                            Expanded(child: Text(sender, style: const TextStyle(color: Colors.white70, fontSize: 13))),
                          ],
                        ),
                      )).toList(),
                    ),
                ] else ...[
                  const Text("Private sender uses your own session. 10 min cooldown applies only to your account.", style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderPanel() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: neonRed.withOpacity(0.3), width: 1),
        boxShadow: [BoxShadow(color: neonRed.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), gradient: neonGradient, boxShadow: [BoxShadow(color: neonRed.withOpacity(0.6), blurRadius: 15, spreadRadius: 2)]),
            child: Container(width: 64, height: 64, padding: const EdgeInsets.all(10), decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)), child: Image.asset('assets/images/logo.png')),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.username, style: const TextStyle(color: Colors.white, fontFamily: 'Orbitron', fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1.0)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: neonRed.withOpacity(0.14), borderRadius: BorderRadius.circular(999), border: Border.all(color: neonRed.withOpacity(0.3))),
                  child: Text("ROLE: ${widget.role.toUpperCase()} • EXP: ${widget.expiredDate}", style: TextStyle(color: neonRed, fontFamily: 'ShareTechMono', fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    if (!_isVideoInitialized) {
      return Container(
        width: double.infinity,
        height: 148,
        margin: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(22)),
        child: Center(child: CircularProgressIndicator(color: neonRed, strokeWidth: 3)),
      );
    }
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(22), boxShadow: [BoxShadow(color: neonRed.withOpacity(0.4), blurRadius: 20, spreadRadius: 2)], border: Border.all(color: neonRed.withOpacity(0.3), width: 1.5)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: AspectRatio(
          aspectRatio: 16 / 6.8,
          child: Stack(
            children: [
              Chewie(controller: _chewieController),
              Container(decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.transparent, neonRed.withOpacity(0.2)], begin: Alignment.topCenter, end: Alignment.bottomCenter))),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedBugMode = "number";
              targetController.clear();
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _selectedBugMode == "number" ? neonRed.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedBugMode == "number" ? neonRed : neonRed.withOpacity(0.3), width: _selectedBugMode == "number" ? 2 : 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_android_rounded, color: _selectedBugMode == "number" ? neonRed : textGrey, size: 20),
                  const SizedBox(width: 8),
                  Text("NUMBER BUG", style: TextStyle(color: _selectedBugMode == "number" ? neonRed : textGrey, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Orbitron')),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() {
              _selectedBugMode = "group";
              targetController.clear();
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: _selectedBugMode == "group" ? neonRed.withOpacity(0.2) : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _selectedBugMode == "group" ? neonRed : neonRed.withOpacity(0.3), width: _selectedBugMode == "group" ? 2 : 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.group_add, color: _selectedBugMode == "group" ? neonRed : textGrey, size: 20),
                  const SizedBox(width: 8),
                  Text("GROUP BUG", style: TextStyle(color: _selectedBugMode == "group" ? neonRed : textGrey, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Orbitron')),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInputPanel() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildModeSelector(),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Text(_selectedBugMode == "number" ? "TARGET NUMBER" : "GROUP LINK", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Orbitron', letterSpacing: 1.5)),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(color: cardBg, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]),
          child: TextField(
            controller: targetController,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            cursorColor: neonRed,
            keyboardType: _selectedBugMode == "number" ? TextInputType.phone : TextInputType.url,
            decoration: InputDecoration(
              hintText: _selectedBugMode == "number" ? "Example: +62xxxxxxxxxx" : "Example: https://chat.whatsapp.com/...",
              hintStyle: TextStyle(color: textGrey.withOpacity(0.5)),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: neonRed.withOpacity(0.3))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFFF2E63), width: 2)),
              prefixIcon: Icon(_selectedBugMode == "number" ? Icons.phone_android_rounded : Icons.link, color: neonRed),
              contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
            ),
          ),
        ),
        const SizedBox(height: 30),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: const Text("SELECT BUG", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14, fontFamily: 'Orbitron', letterSpacing: 1.5)),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: widget.listBug.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final bug = widget.listBug[index];
              final bugId = bug['bug_id']?.toString() ?? '';
              final bugName = bug['bug_name']?.toString() ?? 'Unknown Bug';
              final isSelected = selectedBugId == bugId;
              return GestureDetector(
                onTap: () => _toggleBugSelection(bugId),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? neonRed.withOpacity(0.2) : cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: isSelected ? neonRed : neonRed.withOpacity(0.25), width: isSelected ? 2 : 1.2),
                    boxShadow: isSelected ? [BoxShadow(color: neonRed.withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 4))] : null,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(color: neonRed.withOpacity(0.15), borderRadius: BorderRadius.circular(10)),
                        child: Icon(isSelected ? Icons.check_circle_rounded : Icons.auto_awesome_rounded, color: neonRed, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          bugName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: isSelected ? FontWeight.bold : FontWeight.w600, fontFamily: 'ShareTechMono'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSendButton() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          height: 65,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: neonGradient,
            boxShadow: [BoxShadow(color: neonRed.withOpacity(0.5), blurRadius: _pulseController.value * 25, spreadRadius: _pulseController.value * 2)],
          ),
          child: ElevatedButton(
            onPressed: _isSending ? null : _sendBug,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0, shadowColor: Colors.transparent),
            child: _isSending
                ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 22),
                      SizedBox(width: 12),
                      Text("SEND BUG ATTACK", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18, letterSpacing: 2, fontFamily: 'Orbitron')),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildResponseMessage() {
    if (_responseMessage == null) return const SizedBox.shrink();
    Color bgColor, borderColor, textColor;
    IconData icon;
    if (_responseMessage!.startsWith('SUCCESS')) {
      bgColor = const Color(0xFF00E5A0).withOpacity(0.15);
      borderColor = const Color(0xFF00E5A0);
      textColor = const Color(0xFF00E5A0);
      icon = Icons.check_circle_outline_rounded;
    } else if (_responseMessage!.startsWith('FAILED') || _responseMessage!.startsWith('ERROR') || _responseMessage!.startsWith('INVALID')) {
      bgColor = neonRed.withOpacity(0.15);
      borderColor = neonRed;
      textColor = neonRed;
      icon = Icons.error_outline_rounded;
    } else {
      bgColor = neonRedLight.withOpacity(0.15);
      borderColor = neonRedLight;
      textColor = neonRedLight;
      icon = Icons.info_outline_rounded;
    }
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16), border: Border.all(color: borderColor.withOpacity(0.5), width: 1), boxShadow: [BoxShadow(color: borderColor.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4))]),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 24),
            const SizedBox(width: 12),
            Expanded(child: Text(_responseMessage!, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'ShareTechMono'))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBg,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      MaintenanceBanner(onDismiss: () {}),
                      const SizedBox(height: 16),
                      _buildHeaderPanel(),
                      const SizedBox(height: 14),
                      _buildVideoPlayer(),
                      const SizedBox(height: 18),
                      _buildInputPanel(),
                      _buildSenderTypeSelector(),
                      const SizedBox(height: 34),
                      _buildSendButton(),
                      _buildResponseMessage(),
                    ],
                  ),
                ),
              ),
            ),
          ),
          _buildWelcomeOverlay(),
        ],
      ),
    );
  }
}