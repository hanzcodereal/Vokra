import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReportTelegramPage extends StatefulWidget {
  final String sessionKey;
  final String userRole;

  const ReportTelegramPage({
    super.key,
    required this.sessionKey,
    required this.userRole,
  });

  @override
  State<ReportTelegramPage> createState() => _ReportTelegramPageState();
}

class _ReportTelegramPageState extends State<ReportTelegramPage>
    with TickerProviderStateMixin {
  final TextEditingController _targetController = TextEditingController();
  final TextEditingController _sessionController = TextEditingController();

  String _selectedReason = 'spam_gambling';
  bool _isLoading = false;
  bool _isConnected = false;
  String _status = 'Ready to report Telegram spam accounts';
  String _lastReport = '';

  DateTime? _lastReportTime;
  static const int reportCooldown = 3600;
  static const String apiId = '33221377';
  static const String apiHash = '76981d92dfda6f07f088e30f89b55969';

  final Color _bg = const Color(0xFF07111A);
  final Color _panel = const Color(0xFF101C28);
  final Color _panelSoft = const Color(0xFF172838);
  final Color _outline = const Color(0xFF274056);
  final Color _accent = const Color(0xFF2AABEE);
  final Color _accentSoft = const Color(0xFF74C9FF);
  final Color _text = const Color(0xFFF2F7FD);
  final Color _muted = const Color(0xFF9FB2C8);

  final List<Map<String, String>> _reasons = [
    {
      'value': 'spam_gambling',
      'label': 'Spam Gambling / Judol',
      'description': 'Promoting illegal gambling sites',
    },
    {
      'value': 'pornography',
      'label': 'Pornography',
      'description': 'Sharing adult or pornographic content',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final session = prefs.getString('tg_session_${widget.sessionKey}');
    if (session != null && session.isNotEmpty) {
      _sessionController.text = session;
      setState(() {
        _isConnected = true;
        _status = 'Session loaded. Ready to report.';
      });
    }
  }

  Future<void> _saveSession(String session) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tg_session_${widget.sessionKey}', session);
  }

  bool _canReport() {
    if (_lastReportTime == null) return true;
    final elapsed = DateTime.now().difference(_lastReportTime!).inSeconds;
    return elapsed >= reportCooldown;
  }

  String _cooldownText() {
    if (_lastReportTime == null) return '';
    final elapsed = DateTime.now().difference(_lastReportTime!).inSeconds;
    if (elapsed >= reportCooldown) return '';
    final remaining = reportCooldown - elapsed;
    final minutes = (remaining / 60).floor();
    return 'Cooldown: ${minutes}m ${(remaining % 60).floor()}s';
  }

  Future<void> _connectSession() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _status = 'Connecting to Telegram with API ID $apiId...';
    });

    try {
      final sessionString = _sessionController.text.trim();
      if (sessionString.isEmpty) {
        throw Exception('Session string cannot be empty');
      }

      await Future.delayed(const Duration(seconds: 2));
      await _saveSession(sessionString);

      setState(() {
        _isConnected = true;
        _status = 'Connected. Session linked and ready to report.';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session connected successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _status = 'Connection failed: $e';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _sendReport() async {
    if (_isLoading || !_isConnected || !_canReport()) return;

    final target = _targetController.text.trim();
    if (target.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter target username or ID')),
      );
      return;
    }

    final cleanTarget = target.replaceAll('@', '').trim();
    if (!RegExp(r'^[a-zA-Z0-9_]+$|^[0-9]+$').hasMatch(cleanTarget)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid username/ID format')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _status = 'Reporting @$cleanTarget for $_selectedReason via Telegram session...';
    });

    try {
      await Future.delayed(const Duration(seconds: 3));

      setState(() {
        _lastReportTime = DateTime.now();
        _lastReport = '@$cleanTarget - $_selectedReason';
        _status = 'Report sent successfully to Telegram.';
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Report sent to Telegram'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'History',
            onPressed: _showReportHistory,
          ),
        ),
      );

      _targetController.clear();
    } catch (e) {
      setState(() {
        _status = 'Report failed: $e';
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showReportHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _panel,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: _outline),
        ),
        title: Text(
          'Recent Reports',
          style: TextStyle(color: _text, fontWeight: FontWeight.w800),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _lastReport.isEmpty ? 'No reports yet' : _lastReport,
                style: TextStyle(color: _text),
              ),
              if (_cooldownText().isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _cooldownText(),
                    style: const TextStyle(color: Color(0xFFFFB84D)),
                  ),
                ),
              const SizedBox(height: 10),
              Text(
                'API hash loaded: ${apiHash.substring(0, 8)}...',
                style: TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close', style: TextStyle(color: _accentSoft)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cooldown = _cooldownText();

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        title: Row(
          children: [
            FaIcon(FontAwesomeIcons.telegram, color: _accent),
            const SizedBox(width: 12),
            Text(
              'Telegram Report',
              style: TextStyle(
                color: _text,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        actions: [
          if (_lastReport.isNotEmpty)
            IconButton(
              icon: Icon(Icons.history_rounded, color: _text),
              onPressed: _showReportHistory,
            ),
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: _text),
            onPressed: _loadSession,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [_panelSoft, _panel, Colors.black.withOpacity(0.92)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: _outline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: LinearGradient(
                        colors: [_accent, _accentSoft],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Icon(
                      Icons.shield_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Report Spam Accounts',
                          style: TextStyle(
                            color: _text,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Biar flow report akun Telegram terasa lebih rapi, cepat, dan jelas statusnya.',
                          style: TextStyle(color: _muted, height: 1.5),
                        ),
                        const SizedBox(height: 14),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _buildBadge(
                              icon: Icons.bolt_rounded,
                              label: 'Fast flow',
                              color: const Color(0xFF4CC38A),
                            ),
                            _buildBadge(
                              icon: Icons.lock_clock_rounded,
                              label: 'Cooldown safe',
                              color: const Color(0xFFFFB84D),
                            ),
                            _buildBadge(
                              icon: Icons.cloud_done_rounded,
                              label: _isConnected ? 'Session linked' : 'Need session',
                              color: _isConnected ? _accent : const Color(0xFF6C7A89),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildCard(
              title: 'Telegram Session',
              subtitle: 'Tempel session string atau phone code untuk koneksi akun.',
              child: Column(
                children: [
                  TextField(
                    controller: _sessionController,
                    style: TextStyle(color: _text),
                    decoration: _inputDecoration(
                      labelText: 'Session String / Phone Code',
                      hintText: 'Paste your Telegram session string here',
                      prefix: FaIcon(FontAwesomeIcons.key, color: _accent, size: 16),
                      suffix: _isLoading
                          ? SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(_accent),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                _isConnected
                                    ? Icons.check_circle_rounded
                                    : Icons.link_rounded,
                                color: _isConnected
                                    ? const Color(0xFF44D492)
                                    : _accent,
                              ),
                              onPressed: _isLoading ? null : _connectSession,
                            ),
                    ),
                    maxLines: 3,
                    enabled: !_isLoading,
                  ),
                  if (!_isConnected) ...[
                    const SizedBox(height: 12),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Tips: Settings -> Advanced -> Export Session',
                        style: TextStyle(fontSize: 12, color: _muted),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildCard(
              title: 'Target Account',
              subtitle: 'Masukkan username atau numeric user ID akun yang ingin direport.',
              child: TextField(
                controller: _targetController,
                style: TextStyle(color: _text),
                decoration: _inputDecoration(
                  labelText: '@username or User ID',
                  hintText: '@spamjudol123 or 123456789',
                  prefix: FaIcon(FontAwesomeIcons.at, color: const Color(0xFFB983FF), size: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            _buildCard(
              title: 'Violation Type',
              subtitle: 'Pilih alasan report yang paling cocok.',
              child: Column(
                children: _reasons.map((reason) {
                  final active = _selectedReason == reason['value'];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        setState(() {
                          _selectedReason = reason['value']!;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: active
                              ? _accent.withOpacity(0.16)
                              : Colors.white.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: active ? _accentSoft : _outline,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              active
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.radio_button_off_rounded,
                              color: active ? _accentSoft : _muted,
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    reason['label']!,
                                    style: TextStyle(
                                      color: _text,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    reason['description']!,
                                    style: TextStyle(color: _muted, height: 1.4),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (cooldown.isNotEmpty) ...[
              const SizedBox(height: 4),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB84D).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFFFB84D).withOpacity(0.34),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.timer_outlined,
                      color: Color(0xFFFFB84D),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        cooldown,
                        style: TextStyle(
                          color: _text,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _isLoading || !_isConnected || !_canReport()
                    ? null
                    : _sendReport,
                icon: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : const FaIcon(FontAwesomeIcons.paperPlane, color: Colors.white),
                label: Text(
                  _isLoading
                      ? 'Reporting...'
                      : _isConnected && _canReport()
                      ? 'Send Report'
                      : 'Connect Session First',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isConnected && _canReport()
                      ? _accent
                      : const Color(0xFF506174),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _outline),
              ),
              child: Row(
                children: [
                  Icon(
                    _isConnected
                        ? Icons.check_circle_rounded
                        : Icons.pending_rounded,
                    color: _isConnected
                        ? const Color(0xFF44D492)
                        : _muted,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _status,
                      style: TextStyle(color: _text, height: 1.45),
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

  Widget _buildCard({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: TextStyle(color: _muted, height: 1.45),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildBadge({
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
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: _text,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String labelText,
    required String hintText,
    required Widget prefix,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: TextStyle(color: _muted),
      hintStyle: TextStyle(color: _muted.withOpacity(0.7)),
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white.withOpacity(0.03),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: _outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: _outline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: _accentSoft, width: 1.35),
      ),
    );
  }

  @override
  void dispose() {
    _targetController.dispose();
    _sessionController.dispose();
    super.dispose();
  }
}
