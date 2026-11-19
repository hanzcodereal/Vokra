import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:battery_plus/battery_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:web_socket_channel/web_socket_channel.dart';

// Import halaman lain
import 'api_config.dart';
import 'admin_page.dart';
import 'info_page.dart';
import 'login_page.dart';
import 'owner_page.dart';
import 'profile_page.dart';
import 'riwayat_page.dart';
import 'role_access.dart';
import 'seller_page.dart';
import 'tools_gateway.dart';
import 'about_developer_page.dart';

enum _DashboardView {
  home,
  info,
  tools,
  seller,
  admin,
  owner,
  createAccount,
}

// ==================== GLOBAL FLOATING WINDOW MANAGER ====================
class FloatingWindowManager extends InheritedWidget {
  final bool isVisible;
  final VoidCallback toggleVisibility;
  final VoidCallback showWindow;
  final VoidCallback hideWindow;

  const FloatingWindowManager({
    super.key,
    required this.isVisible,
    required this.toggleVisibility,
    required this.showWindow,
    required this.hideWindow,
    required super.child,
  });

  static FloatingWindowManager? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<FloatingWindowManager>();
  }

  @override
  bool updateShouldNotify(FloatingWindowManager oldWidget) {
    return isVisible != oldWidget.isVisible;
  }
}

// ==================== FLOATING 3D WINDOW WIDGET (ULTRA MODERN) ====================
class Floating3DWindow extends StatefulWidget {
  final Widget child;
  final double initialWidth;
  final double initialHeight;
  final double edgeMargin;
  final VoidCallback? onToggleVisibility;
  final bool isVisible;

  const Floating3DWindow({
    super.key,
    required this.child,
    this.initialWidth = 300,
    this.initialHeight = 460,
    this.edgeMargin = 12,
    this.onToggleVisibility,
    this.isVisible = true,
  });

  @override
  State<Floating3DWindow> createState() => _Floating3DWindowState();
}

class _Floating3DWindowState extends State<Floating3DWindow>
    with SingleTickerProviderStateMixin {
  late AnimationController _rotateController;
  late Animation<double> _rotateXAnim;
  late Animation<double> _rotateYAnim;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late AnimationController _floatController;
  
  Offset _position = const Offset(20, 100);
  Size _size = const Size(300, 460);
  bool _isDragging = false;
  bool _isMinimized = false;
  bool _isHovering = false;
  bool _isExpanded = false;
  
  double _targetRotateX = 0;
  double _targetRotateY = 0;
  double _currentRotateX = 0;
  double _currentRotateY = 0;
  
  final Color _neonRed = const Color(0xFFFF2E63);
  final Color _neonRedLight = const Color(0xFFFF6B8A);
  final Color _neonRedDark = const Color(0xFFC41E3A);
  final Color _glassColor = const Color(0x1AFFFFFF);
  
  final GlobalKey _windowKey = GlobalKey();
  
  @override
  void initState() {
    super.initState();
    
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _rotateXAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOutCubic),
    );
    _rotateYAnim = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOutCubic),
    );
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
    
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
    
    _size = Size(widget.initialWidth, widget.initialHeight);
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenSize = MediaQuery.of(context).size;
      setState(() {
        _position = Offset(
          screenSize.width - widget.initialWidth - widget.edgeMargin,
          screenSize.height * 0.25,
        );
      });
    });
  }
  
  void _updatePosition(DragUpdateDetails details) {
    setState(() {
      _position += details.delta;
      final screenSize = MediaQuery.of(context).size;
      _position = Offset(
        _position.dx.clamp(widget.edgeMargin, 
          screenSize.width - _size.width - widget.edgeMargin),
        _position.dy.clamp(widget.edgeMargin,
          screenSize.height - _size.height - widget.edgeMargin),
      );
    });
  }
  
  void _updateRotation(PointerHoverEvent details) {
    if (_isMinimized) return;
    
    final RenderBox? renderBox = _windowKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    
    final Offset localPos = renderBox.globalToLocal(details.position);
    final double width = renderBox.size.width;
    final double height = renderBox.size.height;
    
    final double rotateY = ((localPos.dx / width) - 0.5) * 25;
    final double rotateX = ((localPos.dy / height) - 0.5) * -15;
    
    setState(() {
      _targetRotateX = rotateX.clamp(-12, 12);
      _targetRotateY = rotateY.clamp(-12, 12);
    });
    
    _rotateXAnim = Tween<double>(begin: _currentRotateX, end: _targetRotateX).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOutCubic),
    );
    _rotateYAnim = Tween<double>(begin: _currentRotateY, end: _targetRotateY).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOutCubic),
    );
    
    _rotateController.forward(from: 0);
  }
  
  void _resetRotation() {
    setState(() {
      _targetRotateX = 0;
      _targetRotateY = 0;
    });
    
    _rotateXAnim = Tween<double>(begin: _currentRotateX, end: 0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOutCubic),
    );
    _rotateYAnim = Tween<double>(begin: _currentRotateY, end: 0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeOutCubic),
    );
    _rotateController.forward(from: 0);
  }
  
  void _toggleMinimize() {
    setState(() {
      _isMinimized = !_isMinimized;
      if (_isMinimized) {
        _size = const Size(70, 70);
      } else {
        _size = Size(widget.initialWidth, widget.initialHeight);
      }
    });
  }
  
  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _size = const Size(360, 560);
      } else {
        _size = Size(widget.initialWidth, widget.initialHeight);
      }
    });
  }
  
  void _toggleVisibility() {
    widget.onToggleVisibility?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();
    
    final floatY = 8 * (_floatController.value - 0.5);
    
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      left: _position.dx,
      top: _position.dy + floatY,
      child: MouseRegion(
        onHover: _updateRotation,
        onExit: (_) => _resetRotation(),
        child: GestureDetector(
          onPanStart: (_) => setState(() => _isDragging = true),
          onPanUpdate: _updatePosition,
          onPanEnd: (_) => setState(() => _isDragging = false),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _size.width,
            height: _size.height,
            curve: Curves.easeOutBack,
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _rotateXAnim, 
                _rotateYAnim, 
                _pulseController, 
                _glowController,
                _floatController
              ]),
              builder: (context, child) {
                _currentRotateX = _rotateXAnim.value;
                _currentRotateY = _rotateYAnim.value;
                final glowIntensity = 0.4 + (0.3 * _glowController.value);
                final pulseScale = 0.96 + (0.04 * _pulseController.value);
                
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()
                    ..setEntry(3, 2, 0.002)
                    ..rotateX(_currentRotateX * 3.14159 / 180)
                    ..rotateY(_currentRotateY * 3.14159 / 180),
                  child: _buildUltraModernWindow(glowIntensity, pulseScale),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildUltraModernWindow(double glowIntensity, double pulseScale) {
    final isMin = _isMinimized;
    
    return Transform.scale(
      scale: pulseScale,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isMin ? 35 : 24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.6),
              blurRadius: 40,
              spreadRadius: 10,
              offset: const Offset(0, 20),
            ),
            BoxShadow(
              color: _neonRed.withOpacity(0.5 * glowIntensity),
              blurRadius: 50 * glowIntensity,
              spreadRadius: 5,
              offset: const Offset(0, 0),
            ),
            BoxShadow(
              color: _neonRedLight.withOpacity(0.3 * glowIntensity),
              blurRadius: 30,
              spreadRadius: -5,
              offset: const Offset(0, 0),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isMin ? 35 : 24),
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 1.5, sigmaY: 1.5),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0C1A31).withOpacity(0.96),
                    const Color(0xFF071225).withOpacity(0.96),
                    const Color(0xFF030917).withOpacity(0.98),
                  ],
                ),
                border: Border.all(
                  color: _neonRed.withOpacity(0.6 + (0.3 * glowIntensity)),
                  width: 1.8,
                ),
              ),
              child: Stack(
                children: [
                  // Animated gradient background
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            center: Alignment.center,
                            radius: 0.9,
                            colors: [
                              _neonRed.withOpacity(0.1),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  // Glassmorphism overlay
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Colors.white.withOpacity(0.03),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  
                  if (!isMin)
                    Column(
                      children: [
                        _buildUltraTitleBar(glowIntensity),
                        Expanded(child: widget.child),
                        _buildNeonFooter(),
                      ],
                    )
                  else
                    Center(
                      child: AnimatedScale(
                        scale: 1 + (0.1 * _pulseController.value),
                        duration: const Duration(milliseconds: 500),
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [_neonRed, _neonRedDark],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(23),
                            boxShadow: [
                              BoxShadow(
                                color: _neonRed.withOpacity(0.8),
                                blurRadius: 20,
                                spreadRadius: 3,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.flash_on_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildUltraTitleBar(double glowIntensity) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _neonRed.withOpacity(0.4 + (0.2 * glowIntensity)),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          // Animated dots
          _buildNeonDot(const Color(0xFFFF5F56), Colors.red),
          const SizedBox(width: 8),
          _buildNeonDot(const Color(0xFFFFBD2E), Colors.orange),
          const SizedBox(width: 8),
          _buildNeonDot(const Color(0xFF27C93F), Colors.green),
          const Spacer(),
          // Title text
          Text(
            "⚡ QUICK ACCESS",
            style: TextStyle(
              fontFamily: 'Orbitron',
              fontSize: 11,
              color: _neonRed,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // Expand button
          GestureDetector(
            onTap: _toggleExpand,
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: _neonRed.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _neonRed.withOpacity(0.4)),
              ),
              child: Icon(
                _isExpanded ? Icons.compress_rounded : Icons.open_in_full_rounded,
                color: _neonRed,
                size: 16,
              ),
            ),
          ),
          // Minimize button
          GestureDetector(
            onTap: _toggleMinimize,
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: _neonRed.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _neonRed.withOpacity(0.4)),
              ),
              child: Icon(
                Icons.remove_rounded,
                color: _neonRed,
                size: 16,
              ),
            ),
          ),
          // Close button
          GestureDetector(
            onTap: _toggleVisibility,
            child: Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: _neonRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _neonRed.withOpacity(0.5)),
              ),
              child: Icon(
                Icons.close_rounded,
                color: _neonRed,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildNeonDot(Color color, Color glowColor) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.6),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
    );
  }
  
  Widget _buildNeonFooter() {
    return Container(
      height: 32,
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: _neonRed.withOpacity(0.3),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flash_on_rounded,
            color: _neonRed,
            size: 14,
          ),
          const SizedBox(width: 6),
          Text(
            "SixEyesX v8.5",
            style: TextStyle(
              fontFamily: 'ShareTechMono',
              fontSize: 9,
              color: Colors.white54,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
  
  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    _glowController.dispose();
    _floatController.dispose();
    super.dispose();
  }
}

// ==================== FLOATING TOOLS CONTENT ====================
class FloatingToolsContent extends StatelessWidget {
  final String sessionKey;
  final String username;
  final String role;
  final VoidCallback onClose;
  
  const FloatingToolsContent({
    super.key,
    required this.sessionKey,
    required this.username,
    required this.role,
    required this.onClose,
  });
  
  @override
  Widget build(BuildContext context) {
    final neonRed = const Color(0xFFFF2E63);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [neonRed, neonRed.withOpacity(0.6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: neonRed.withOpacity(0.6),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Icon(Icons.flash_on_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "IMMORTAL X",
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 12,
                      color: neonRed,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "QUICK PANEL",
                    style: TextStyle(
                      fontFamily: 'Orbitron',
                      fontSize: 9,
                      color: Colors.white54,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildGlassToolItem(
            icon: Icons.history_rounded,
            label: "Riwayat",
            subtitle: "View activity log",
            color: neonRed,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RiwayatPage(sessionKey: sessionKey, role: role),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassToolItem(
            icon: Icons.developer_mode_rounded,
            label: "Developer About",
            subtitle: "About Developer",
            color: neonRed,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => AboutDeveloperPage(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassToolItem(
            icon: Icons.person_rounded,
            label: "Profile",
            subtitle: "Manage account",
            color: neonRed,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ProfilePage(
                  username: username,
                  password: "",
                  role: role,
                  expiredDate: "",
                  sessionKey: sessionKey,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildGlassToolItem(
            icon: Icons.color_lens_rounded,
            label: "Theme",
            subtitle: "Change appearance",
            color: neonRed,
            onTap: () {},
          ),
          const Spacer(),
          Divider(color: neonRed.withOpacity(0.2), height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.battery_5_bar_rounded, color: neonRed, size: 14),
              const SizedBox(width: 6),
              Text(
                "System Online",
                style: TextStyle(color: Colors.white54, fontSize: 10),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: neonRed.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: neonRed.withOpacity(0.3)),
                ),
                child: Text(
                  role.toUpperCase().substring(0, role.length > 4 ? 4 : role.length),
                  style: TextStyle(
                    color: neonRed,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildGlassToolItem({
    required IconData icon,
    required String label,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.12), color.withOpacity(0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.35), width: 0.8),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

// ==================== DASHBOARD PAGE WITH FLOATING WINDOW ====================
class DashboardPage extends StatefulWidget {
  final String username;
  final String password;
  final String role;
  final String expiredDate;
  final String sessionKey;
  final String telegramId;
  final List<Map<String, dynamic>> listBug;
  final List<Map<String, dynamic>> listDoos;
  final List<dynamic> news;

  const DashboardPage({
    super.key,
    required this.username,
    required this.password,
    required this.role,
    required this.expiredDate,
    required this.listBug,
    required this.listDoos,
    required this.sessionKey,
    required this.telegramId,
    required this.news,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  WebSocketChannel? _channel;

  // State Variabel
  late String sessionKey;
  late String username;
  late String password;
  late String role;
  late String expiredDate;
  late String telegramId;
  late List<Map<String, dynamic>> listBug;
  late List<Map<String, dynamic>> listDoos;
  late List<dynamic> newsList;
  List<Map<String, String>> animeHighlights = [];
  bool _isAnimeLoading = true;
  String _cityLabel = "Mendeteksi kota...";
  VideoPlayerController? _heroVideoController;
  bool _isHeroVideoReady = false;
  bool _isHeroVideoPlaying = false;
  final Battery _battery = Battery();
  int? _batteryLevel;

  String androidId = "unknown";
  File? _profileImage;

  // Navigasi & Menu
  _DashboardView _currentView = _DashboardView.home;
  bool _isFloatingVisible = true;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  
  // Statistik
  int onlineUsers = 0;
  int activeConnections = 0;

  // Warna Tema Modern
  final Color bgDark = const Color(0xFF030917);
  final Color bgLayer = const Color(0xFF071225);
  final Color panel = const Color(0xFF0C1A31);
  final Color panelStrong = const Color(0xFF122544);
  final Color surfaceSoft = const Color(0xFF0A1426);
  Color outline = const Color(0xFFFF2E63);
  Color accentBlue = const Color(0xFFFF2E63);
  Color accentMint = const Color(0xFFFF6B8A);
  Color accentAmber = const Color(0xFFFF9BAB);
  final Color danger = const Color(0xFFFF2E63);
  final Color textPrimary = const Color(0xFFF3F8FF);
  final Color textMuted = const Color(0xFF9CB3D1);

  @override
  void initState() {
    super.initState();
    sessionKey = widget.sessionKey;
    username = widget.username;
    password = widget.password;
    role = widget.role;
    expiredDate = widget.expiredDate;
    telegramId = widget.telegramId;
    listBug = widget.listBug;
    listDoos = widget.listDoos;
    newsList = widget.news;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();

    _loadThemePreferences();
    _initAndroidIdAndConnect();
    _loadProfileImage();
    _loadCityLabel();
    _loadAnimeHighlights();
    _initializeHeroVideo();
    _loadBatteryLevel();
  }

  Future<void> _loadThemePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final primaryValue = prefs.getInt('dashboard_accent_primary');
    final secondaryValue = prefs.getInt('dashboard_accent_secondary');
    final outlineValue = prefs.getInt('dashboard_accent_outline');
    if (!mounted) return;
    setState(() {
      if (primaryValue != null) accentBlue = Color(primaryValue);
      if (secondaryValue != null) accentMint = Color(secondaryValue);
      if (outlineValue != null) outline = Color(outlineValue);
      accentAmber = Color.lerp(accentBlue, accentMint, 0.45) ?? accentAmber;
    });
  }

  Future<void> _initAndroidIdAndConnect() async {
    final prefs = await SharedPreferences.getInstance();
    try {
      final deviceInfo = await DeviceInfoPlugin().androidInfo;
      androidId = deviceInfo.id;
    } catch (_) {
      androidId = prefs.getString('android_id') ?? androidId;
    }
    if (androidId.trim().isEmpty || androidId == "unknown") {
      androidId = prefs.getString('android_id') ?? "unknown_device";
    }
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    _channel?.sink.close();
    _channel = WebSocketChannel.connect(Uri.parse(wsBaseUrl));
    _channel?.sink.add(
      jsonEncode({
        "type": "validate",
        "key": sessionKey,
        "androidId": androidId,
      }),
    );
    _channel?.sink.add(jsonEncode({"type": "stats"}));
    _channel?.stream.listen((event) {
      final data = jsonDecode(event);
      if (data['type'] == 'myInfo' && data['valid'] == false) {
        final reason = (data['reason'] ?? '').toString();
        final message = reason == 'androidIdMismatch'
            ? "Sesi perangkat berubah. Silakan login ulang."
            : "Sesi tidak valid. Login ulang.";
        _handleInvalidSession(message);
      }
      if (data['type'] == 'stats' && mounted) {
        setState(() {
          onlineUsers = data['onlineUsers'] ?? 0;
          activeConnections = data['activeConnections'] ?? 0;
        });
      }
    }, onError: (_) {});
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final imagePath = prefs.getString('profile_image_$username');
    if (imagePath == null || imagePath.isEmpty) return;
    final file = File(imagePath);
    if (!await file.exists() || !mounted) return;
    setState(() => _profileImage = file);
  }

  Future<void> _loadCityLabel() async {
    try {
      final response = await http.get(
        Uri.parse('https://ipapi.co/json/'),
        headers: const {'Accept': 'application/json'},
      );
      if (response.statusCode != 200) throw Exception('failed');
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final city = (data['city'] ?? '').toString().trim();
      final countryCode = (data['country_code'] ?? '').toString().trim();
      final nextLabel = [
        if (city.isNotEmpty) city.toUpperCase(),
        if (countryCode.isNotEmpty) countryCode.toUpperCase(),
      ].join(', ');
      if (!mounted) return;
      setState(() {
        _cityLabel = nextLabel.isNotEmpty ? nextLabel : 'LOKASI TIDAK DIKETAHUI';
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _cityLabel = 'LOKASI TIDAK TERSEDIA');
    }
  }

  Future<void> _loadBatteryLevel() async {
    try {
      final level = await _battery.batteryLevel;
      if (!mounted) return;
      setState(() => _batteryLevel = level);
    } catch (_) {
      if (!mounted) return;
      setState(() => _batteryLevel = null);
    }
  }

  Future<void> _loadAnimeHighlights() async {
    try {
      final response = await http.get(Uri.parse('https://www.sankavollerei.com/anime/home'));
      if (response.statusCode != 200) throw Exception('failed');
      final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
      final data = jsonData['data'] as Map<String, dynamic>? ?? {};
      final ongoing = (data['ongoing'] as Map<String, dynamic>?)?['animeList'] as List? ?? [];
      final completed = (data['completed'] as Map<String, dynamic>?)?['animeList'] as List? ?? [];
      final combined = [...ongoing, ...completed];
      final parsed = combined
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .where((item) => (item['title'] ?? '').toString().trim().isNotEmpty)
          .take(3)
          .map((item) => {
                'title': (item['title'] ?? '-').toString(),
                'subtitle': (item['latestReleaseDate'] ?? item['lastReleaseDate'] ?? 'Anime update').toString(),
                'image': (item['poster'] ?? '').toString(),
                'episode': (item['episodes'] ?? '').toString(),
              })
          .toList();
      if (!mounted) return;
      setState(() {
        animeHighlights = parsed;
        _isAnimeLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        animeHighlights = [];
        _isAnimeLoading = false;
      });
    }
  }

  Future<void> _initializeHeroVideo() async {
    final controller = VideoPlayerController.asset('assets/videos/video.mp4');
    _heroVideoController = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (!mounted) return;
      setState(() {
        _isHeroVideoReady = true;
        _isHeroVideoPlaying = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isHeroVideoReady = false;
        _isHeroVideoPlaying = false;
      });
    }
  }

  Future<void> _toggleHeroVideo() async {
    final controller = _heroVideoController;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      await controller.pause();
    } else {
      await controller.play();
    }
    if (!mounted) return;
    setState(() => _isHeroVideoPlaying = controller.value.isPlaying);
  }

  void _handleInvalidSession(String message) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: panelStrong,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text("SESSION EXPIRED", style: _headlineStyle(color: accentBlue)),
        content: Text(message, style: _bodyStyle(color: textMuted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            ),
            child: Text("OK", style: _bodyStyle(color: accentBlue, weight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _openUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal membuka link")),
        );
      }
    }
  }

  void _copySessionKey() async {
    await Clipboard.setData(ClipboardData(text: telegramId.isNotEmpty ? telegramId : sessionKey));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: panelStrong,
        content: Text("Session key copied", style: _bodyStyle(color: textPrimary, weight: FontWeight.bold)),
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfilePage(
          username: username,
          password: password,
          role: role,
          expiredDate: expiredDate,
          sessionKey: sessionKey,
        ),
      ),
    );
  }

  void _openHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RiwayatPage(sessionKey: sessionKey, role: role),
      ),
    );
  }

  void _toggleFloating() => setState(() => _isFloatingVisible = !_isFloatingVisible);
  void _setView(_DashboardView view) => setState(() => _currentView = view);
  void _navigateTo(_DashboardView view) { _setView(view); Navigator.of(context).pop(); }

  // ==================== BUILD UI ====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: bgDark,
      drawerScrimColor: Colors.black87,
      body: Stack(
        children: [
          _buildBackdrop(),
          SafeArea(
            child: FadeTransition(
              opacity: _animation,
              child: Column(
                children: [
                  _buildModernHeader(),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 320),
                      child: KeyedSubtree(
                        key: ValueKey(_currentView),
                        child: _buildSelectedContent(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Floating 3D Window
          if (_isFloatingVisible)
            Floating3DWindow(
              initialWidth: 300,
              initialHeight: 480,
              isVisible: _isFloatingVisible,
              onToggleVisibility: _toggleFloating,
              child: FloatingToolsContent(
                sessionKey: sessionKey,
                username: username,
                role: role,
                onClose: _toggleFloating,
              ),
            ),
        ],
      ),
      drawer: _buildGlassDrawer(),
    );
  }

  Widget _buildModernHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [accentMint.withOpacity(0.25), accentBlue.withOpacity(0.12)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: accentBlue.withOpacity(0.4)),
                boxShadow: [BoxShadow(color: accentMint.withOpacity(0.2), blurRadius: 18, offset: const Offset(0, 6))],
              ),
              child: Icon(Icons.menu_rounded, color: accentBlue, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: _buildBrandBanner()),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _openProfile,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: outline.withOpacity(0.45)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _profileImage != null
                    ? Image.file(_profileImage!, fit: BoxFit.cover)
                    : Icon(Icons.person_rounded, color: Colors.white70, size: 28),
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _toggleFloating,
            child: Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _isFloatingVisible ? accentMint.withOpacity(0.15) : Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _isFloatingVisible ? accentBlue.withOpacity(0.5) : outline.withOpacity(0.45)),
              ),
              child: Icon(
                _isFloatingVisible ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _isFloatingVisible ? accentBlue : Colors.white54,
                size: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandBanner() {
    return Container(
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: outline.withOpacity(0.45)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset('assets/images/reze.png', fit: BoxFit.cover, alignment: Alignment.topCenter),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.black.withOpacity(0.72), bgLayer.withOpacity(0.35), Colors.black.withOpacity(0.62)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Container(
                    width: 34, height: 34,
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.35),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: accentBlue.withOpacity(0.35)),
                    ),
                    child: Image.asset('assets/images/logo.png'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "SixEyesX",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: _headlineStyle(size: 14, color: textPrimary, letterSpacing: 1.6),
                        ),
                        Text(
                          "secure access node",
                          style: _bodyStyle(size: 10, color: accentBlue, weight: FontWeight.bold),
                        ),
                      ],
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

  Widget _buildGlassDrawer() {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      width: MediaQuery.of(context).size.width * 0.8,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.97), bgLayer.withOpacity(0.97), Colors.black.withOpacity(0.98)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          border: Border(right: BorderSide(color: outline.withOpacity(0.55))),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDrawerHeader(),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    _buildDrawerSection("MAINFRAME"),
                    _buildDrawerItem(Icons.dashboard_rounded, "Dashboard", view: _DashboardView.home),
                    _buildDrawerItem(Icons.grid_view_rounded, "Tool Matrix", view: _DashboardView.tools),
                    _buildDrawerItem(Icons.feed_outlined, "Intel Feed", view: _DashboardView.info),
                    const SizedBox(height: 16),
                    _buildDrawerSection("ACCESS"),
                    _buildDrawerItem(Icons.storefront_rounded, "Reseller Panel", view: _DashboardView.seller),
                    if (canOpenAccountManager(role))
                      _buildDrawerItem(Icons.admin_panel_settings_rounded, "Admin Panel", view: _DashboardView.admin),
                    if (canOpenOwnerPanel(role))
                      _buildDrawerItem(Icons.workspace_premium_rounded, "Owner Root", view: _DashboardView.owner),
                    const SizedBox(height: 16),
                    _buildDrawerSection("SYSTEM"),
                    _buildDrawerItem(Icons.tune_rounded, "App Settings", onTap: _openProfile),
                    _buildDrawerItem(Icons.history_toggle_off_rounded, "Session Log", onTap: _openHistory),
                    const SizedBox(height: 10),
                    _buildDrawerItem(Icons.power_settings_new_rounded, "Exit Session", isLogout: true),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: outline.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Container(
            width: 56, height: 56,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentMint.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: accentBlue.withOpacity(0.45)),
            ),
            child: Image.asset('assets/images/logo.png'),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("SixEyesX V8.5", style: _headlineStyle(size: 22, color: textPrimary, letterSpacing: 1.2)),
                const SizedBox(height: 4),
                Text(role.toUpperCase(), style: _bodyStyle(color: accentBlue, size: 13, weight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String label, {_DashboardView? view, bool isLogout = false, VoidCallback? onTap}) {
    final isActive = view != null && _currentView == view;
    return InkWell(
      onTap: () {
        if (isLogout) _handleInvalidSession("Logging out...");
        else if (onTap != null) { Navigator.of(context).pop(); onTap(); }
        else if (view != null) _navigateTo(view);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: isActive ? accentMint.withOpacity(0.14) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isActive ? accentBlue.withOpacity(0.35) : outline.withOpacity(0.12)),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 4, height: 32,
              decoration: BoxDecoration(color: isActive ? accentBlue : Colors.transparent, borderRadius: BorderRadius.circular(999)),
            ),
            const SizedBox(width: 14),
            Icon(icon, color: isLogout ? danger : (isActive ? accentBlue : Colors.white70), size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Text(label, style: _bodyStyle(size: 15, weight: isActive ? FontWeight.bold : FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerSection(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 8),
      child: Text(
        label,
        style: _bodyStyle(size: 11, color: Colors.white38, weight: FontWeight.bold).copyWith(letterSpacing: 3),
      ),
    );
  }

  Widget _buildSelectedContent() {
    switch (_currentView) {
      case _DashboardView.home:
        return _buildModernHome();
      case _DashboardView.info:
        return InfoPage(sessionKey: sessionKey);
      case _DashboardView.tools:
        return ToolsPage(sessionKey: sessionKey, userRole: role, listDoos: listDoos);
      case _DashboardView.createAccount:
        return _buildCreateAccountPage();
      case _DashboardView.seller:
        return SellerPage(keyToken: sessionKey);
      case _DashboardView.admin:
        return AdminPage(sessionKey: sessionKey, currentRole: role);
      case _DashboardView.owner:
        return OwnerPage(sessionKey: sessionKey, username: username);
    }
  }

  Widget _buildModernHome() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroCard(),
          const SizedBox(height: 22),
          _buildSectionHeader("FEATURED", actionLabel: "MORE"),
          const SizedBox(height: 12),
          const SizedBox(height: 24),
          _buildSectionHeader("NEWS & UPDATES"),
          const SizedBox(height: 12),
          _buildSingleNewsCard(),
          const SizedBox(height: 16),
          _buildQuickActions(),
        ],
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [Colors.white.withOpacity(0.04), panelStrong.withOpacity(0.92), panel.withOpacity(0.95)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: accentBlue.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 24, offset: const Offset(0, 12)),
          BoxShadow(color: accentBlue.withOpacity(0.15), blurRadius: 30),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(color: accentMint.withOpacity(0.14), shape: BoxShape.circle),
                child: ClipOval(
                  child: _profileImage != null
                      ? Image.file(_profileImage!, fit: BoxFit.cover)
                      : Icon(Icons.person, color: accentBlue, size: 32),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(username, style: _headlineStyle(size: 22)),
                    const SizedBox(height: 4),
                    Text("ID: ${_trimValue(telegramId.isNotEmpty ? telegramId : sessionKey, 12)}",
                        style: _bodyStyle(size: 12, color: textMuted, weight: FontWeight.w600)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: outline.withOpacity(0.45)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.battery_full_rounded, color: accentBlue, size: 18),
                    const SizedBox(width: 6),
                    Text(_batteryLevel != null ? '$_batteryLevel%' : '--%',
                        style: _bodyStyle(size: 12, color: textPrimary, weight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: _copySessionKey,
                child: Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: outline.withOpacity(0.45)),
                  ),
                  child: Icon(Icons.content_copy_rounded, color: Colors.white70, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: outline.withOpacity(0.28)),
          const SizedBox(height: 20),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white, boxShadow: [
                  BoxShadow(color: accentBlue.withOpacity(0.15), blurRadius: 14),
                ]),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: _isHeroVideoReady && _heroVideoController != null
                      ? VideoPlayer(_heroVideoController!)
                      : Container(color: Colors.white, alignment: Alignment.center,
                          child: Icon(Icons.play_arrow_rounded, color: accentBlue, size: 52)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoLine(label: "ROLE", value: role.toUpperCase(), icon: Icons.shield_outlined),
                    const SizedBox(height: 10),
                    _buildInfoLine(label: "EXP DATE", value: _formatExpiryDate(expiredDate), icon: Icons.event_available_outlined),
                    const SizedBox(height: 10),
                    _buildInfoLine(label: "ONLINE", value: "$onlineUsers users", icon: Icons.people_alt_outlined),
                    const SizedBox(height: 10),
                    _buildInfoLine(label: "CONNECTIONS", value: "$activeConnections active", icon: Icons.hub_outlined),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isHeroVideoReady ? _toggleHeroVideo : null,
              icon: Icon(_isHeroVideoPlaying ? Icons.pause_circle_outline : Icons.play_circle_outline, size: 18),
              label: Text(_isHeroVideoPlaying ? "Pause Video" : "Play Video"),
              style: OutlinedButton.styleFrom(
                foregroundColor: textPrimary,
                side: BorderSide(color: outline.withOpacity(0.55)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.place_outlined, color: accentBlue, size: 16),
              const SizedBox(width: 6),
              Text(_cityLabel, style: _bodyStyle(size: 12, color: textMuted, weight: FontWeight.bold)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: accentBlue.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text("ROLE: ${role.toUpperCase()}", style: _bodyStyle(size: 10, color: accentBlue, weight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLine({required String label, required String value, required IconData icon}) {
    return Row(
      children: [
        Padding(padding: const EdgeInsets.only(top: 2), child: Icon(icon, color: Colors.white60, size: 16)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: _bodyStyle(size: 10, color: Colors.white38, weight: FontWeight.bold).copyWith(letterSpacing: 2.4)),
              const SizedBox(height: 3),
              Text(value, style: _bodyStyle(size: 15, color: label == "ROLE" ? accentBlue : textPrimary, weight: FontWeight.bold)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNeonBtn(String label, IconData icon, VoidCallback onTap, {bool isOutline = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isOutline ? Colors.transparent : accentBlue,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: isOutline ? outline.withOpacity(0.55) : accentBlue.withOpacity(0.1)),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isOutline ? textMuted : bgDark, size: 18),
              const SizedBox(width: 8),
              Text(label, style: _bodyStyle(weight: FontWeight.bold, color: isOutline ? textPrimary : bgDark)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, {String? actionLabel}) {
    return Row(
      children: [
        Container(width: 4, height: 36, decoration: BoxDecoration(color: accentBlue, borderRadius: BorderRadius.circular(99))),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _headlineStyle(size: 22)),
              Text(title == "FEATURED" ? "live operator cards" : "activity stream", style: _bodyStyle(size: 12, color: textMuted)),
            ],
          ),
        ),
        if (actionLabel != null)
          TextButton(
            onPressed: () => _setView(_DashboardView.info),
            child: Text(actionLabel, style: _bodyStyle(size: 12, color: Colors.white54, weight: FontWeight.bold)),
          ),
      ],
    );
  }

  Widget _buildSingleNewsCard() {
    final item = newsList.isNotEmpty ? newsList.first : null;
    if (item == null) return const SizedBox.shrink();
    return _quickItem(
      (item['title'] ?? 'DarkVerse Feed').toString(),
      (item['desc'] ?? 'Live system update').toString(),
      Icons.newspaper_rounded,
      accentBlue,
      () => _setView(_DashboardView.info),
    );
  }

  Widget _quickItem(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: outline.withOpacity(0.45)),
        ),
        child: Row(
          children: [
            Container(width: 48, height: 48,
                decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: color)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _bodyStyle(size: 15, weight: FontWeight.bold, color: textPrimary)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: _bodyStyle(size: 11, color: textMuted, weight: FontWeight.w600)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      children: [
        _quickItem("Profile Node", "Manage avatar, password, and account details.", Icons.person_outline_rounded, accentBlue, _openProfile),
        const SizedBox(height: 12),
        _quickItem("Session Log", "Review recent activity and access history.", Icons.history_toggle_off_rounded, accentAmber, _openHistory),
      ],
    );
  }

  Widget _buildCreateAccountPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("ADMINISTRATION", style: _headlineStyle(size: 14, color: textMuted)),
          const SizedBox(height: 10),
          Text("Manage Accounts", style: _headlineStyle(size: 26)),
          const SizedBox(height: 20),
          _buildAdminCard(
            icon: Icons.supervisor_account,
            title: "Generate New User",
            desc: "Buat akun baru untuk member atau reseller.",
            color: accentMint,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Feature coming soon"))),
          ),
          const SizedBox(height: 20),
          _buildAdminCard(
            icon: Icons.list_alt,
            title: "View All Accounts",
            desc: "Lihat daftar akun yang sudah dibuat.",
            color: accentBlue,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Feature coming soon"))),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminCard({required IconData icon, required String title, required String desc, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [panelStrong, panel]),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: outline),
        ),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: color, size: 24)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: _bodyStyle(size: 16, weight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(desc, style: _bodyStyle(size: 12, color: textMuted)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: textMuted, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBackdrop() {
    return IgnorePointer(
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [bgDark, bgLayer, const Color(0xFF0B2417).withOpacity(0.85)],
                stops: [0.0, 0.6, 1.0],
              ),
            ),
          ),
          Positioned.fill(
            child: Opacity(opacity: 0.1, child: Image.asset('assets/images/reze.png', fit: BoxFit.cover, alignment: Alignment.topCenter)),
          ),
          Positioned(top: -60, right: -80, child: _glow(accentBlue, 240)),
          Positioned(bottom: -120, left: -80, child: _glow(accentMint, 260)),
          Container(color: Colors.black.withOpacity(0.32)),
        ],
      ),
    );
  }

  Widget _glow(Color c, double s) => Container(width: s, height: s, decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [c.withOpacity(0.12), Colors.transparent])));

  String _formatExpiryDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return DateFormat('yyyy-MM-dd').format(parsed);
  }

  String _trimValue(String value, int visibleChars) {
    if (value.length <= visibleChars) return value;
    return "${value.substring(0, visibleChars)}...";
  }

  TextStyle _headlineStyle({double size = 20, FontWeight? weight, Color? color, double letterSpacing = 0}) => TextStyle(
    fontFamily: 'Orbitron',
    fontSize: size,
    fontWeight: weight ?? FontWeight.bold,
    color: color ?? textPrimary,
    letterSpacing: letterSpacing,
  );
  
  TextStyle _bodyStyle({double size = 14, FontWeight? weight = FontWeight.w500, Color? color}) => TextStyle(
    fontFamily: 'ShareTechMono',
    fontSize: size,
    fontWeight: weight,
    color: color ?? textMuted,
  );

  @override
  void dispose() {
    _channel?.sink.close(status.goingAway);
    _controller.dispose();
    _heroVideoController?.dispose();
    super.dispose();
  }
}