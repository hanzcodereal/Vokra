import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  final math.Random _random = math.Random();
  final List<_Orb> _orbs = [];

  Timer? _gameTimer;
  Timer? _spawnTimer;
  int _timeLeft = 30;
  int _score = 0;
  int _combo = 0;
  bool _isPlaying = false;

  final Color bg = const Color(0xFF07111F);
  final Color panel = const Color(0xFF102238);
  final Color accent = const Color(0xFF67E8F9);
  final Color accentStrong = const Color(0xFF38BDF8);
  final Color warning = const Color(0xFFF97316);
  final Color textPrimary = const Color(0xFFF8FBFF);
  final Color textMuted = const Color(0xFF94A9C5);

  @override
  void initState() {
    super.initState();
    _startGame();
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();
    super.dispose();
  }

  void _startGame() {
    _gameTimer?.cancel();
    _spawnTimer?.cancel();

    setState(() {
      _orbs.clear();
      _timeLeft = 30;
      _score = 0;
      _combo = 0;
      _isPlaying = true;
    });

    _spawnTimer = Timer.periodic(const Duration(milliseconds: 650), (_) {
      if (!mounted || !_isPlaying) return;
      setState(() {
        _orbs.add(
          _Orb(
            id: DateTime.now().microsecondsSinceEpoch.toString(),
            x: 0.08 + (_random.nextDouble() * 0.74),
            y: 0.12 + (_random.nextDouble() * 0.72),
            size: 44 + _random.nextDouble() * 26,
            color: _random.nextBool() ? accent : warning,
          ),
        );
        if (_orbs.length > 8) {
          _orbs.removeAt(0);
          _combo = 0;
        }
      });
    });

    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_timeLeft <= 1) {
        timer.cancel();
        _spawnTimer?.cancel();
        setState(() {
          _timeLeft = 0;
          _isPlaying = false;
        });
        return;
      }

      setState(() {
        _timeLeft -= 1;
      });
    });
  }

  void _hitOrb(String id) {
    if (!_isPlaying) return;

    setState(() {
      _orbs.removeWhere((orb) => orb.id == id);
      _combo += 1;
      _score += 10 + ((_combo > 1 ? _combo - 1 : 0) * 2);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Neon Tap Rush',
                style: TextStyle(
                  color: textPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Orbitron',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tap orb secepat mungkin dalam 30 detik. Semakin panjang combo, semakin besar skornya.',
                style: TextStyle(
                  color: textMuted,
                  fontSize: 12,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.timer_outlined,
                      label: 'TIME',
                      value: '$_timeLeft s',
                      color: warning,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.bolt_rounded,
                      label: 'COMBO',
                      value: 'x$_combo',
                      color: accent,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      icon: Icons.emoji_events_outlined,
                      label: 'SCORE',
                      value: '$_score',
                      color: accentStrong,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: accent.withOpacity(0.28)),
                    gradient: LinearGradient(
                      colors: [
                        panel.withOpacity(0.96),
                        const Color(0xFF09182D),
                        bg,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.08),
                        blurRadius: 24,
                        offset: const Offset(0, 14),
                      ),
                    ],
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return Stack(
                        children: [
                          Positioned(
                            left: 18,
                            top: 18,
                            right: 18,
                            child: Text(
                              _isPlaying
                                  ? 'Tekan orb biru atau oranye sebelum hilang.'
                                  : 'Game selesai. Geser ke tools lain atau main lagi.',
                              style: TextStyle(
                                color: textMuted,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          ..._orbs.map((orb) {
                            final left = orb.x * constraints.maxWidth;
                            final top = orb.y * constraints.maxHeight;
                            return Positioned(
                              left: left,
                              top: top,
                              child: GestureDetector(
                                onTap: () => _hitOrb(orb.id),
                                child: Container(
                                  width: orb.size,
                                  height: orb.size,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        Colors.white,
                                        orb.color.withOpacity(0.95),
                                        orb.color.withOpacity(0.18),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: orb.color.withOpacity(0.45),
                                        blurRadius: 18,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                          if (!_isPlaying)
                            Center(
                              child: Container(
                                width: 260,
                                padding: const EdgeInsets.all(22),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.44),
                                  borderRadius: BorderRadius.circular(26),
                                  border: Border.all(
                                    color: accentStrong.withOpacity(0.34),
                                  ),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      'Final Score',
                                      style: TextStyle(
                                        color: textMuted,
                                        fontSize: 12,
                                        letterSpacing: 2,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      '$_score',
                                      style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 42,
                                        fontWeight: FontWeight.w900,
                                        fontFamily: 'Orbitron',
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        onPressed: _startGame,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: accentStrong,
                                          foregroundColor: bg,
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 14,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(18),
                                          ),
                                        ),
                                        child: const Text('Main Lagi'),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: panel.withOpacity(0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 14),
          Text(
            label,
            style: TextStyle(
              color: textMuted,
              fontSize: 11,
              letterSpacing: 1.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _Orb {
  final String id;
  final double x;
  final double y;
  final double size;
  final Color color;

  const _Orb({
    required this.id,
    required this.x,
    required this.y,
    required this.size,
    required this.color,
  });
}
