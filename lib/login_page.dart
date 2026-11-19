import 'package:flutter/material.dart';
import 'dashboard_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _username = TextEditingController();
  final _password = TextEditingController();
  bool _hidePassword = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    super.dispose();
  }

  void _login() {
    if (_loading) return;
    if (_username.text.trim() != 'hanz' || _password.text != 'hanz1') {
      setState(() => _error = 'Username atau password salah.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const DashboardPage(
          username: 'hanz',
          password: 'hanz1',
          role: 'developer',
          expiredDate: 'Lifetime',
          listBug: <Map<String, dynamic>>[],
          listDoos: <Map<String, dynamic>>[],
          sessionKey: 'local-vokra-session',
          telegramId: '',
          news: <dynamic>[],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF00D4FF);
    return Scaffold(
      backgroundColor: const Color(0xFF05050A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 92,
                    height: 92,
                    decoration: BoxDecoration(
                      color: const Color(0xFF11111F),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: accent.withOpacity(.55)),
                    ),
                    child: const Icon(Icons.shield_moon_outlined, color: accent, size: 48),
                  ),
                  const SizedBox(height: 24),
                  const Text('VOKRA', style: TextStyle(
                    color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold,
                    letterSpacing: 5, fontFamily: 'Orbitron',
                  )),
                  const SizedBox(height: 8),
                  const Text('SIGN IN', style: TextStyle(color: accent, letterSpacing: 3)),
                  const SizedBox(height: 36),
                  TextField(
                    controller: _username,
                    style: const TextStyle(color: Colors.white),
                    textInputAction: TextInputAction.next,
                    decoration: _decoration('Username', Icons.person_outline),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _password,
                    obscureText: _hidePassword,
                    onSubmitted: (_) => _login(),
                    style: const TextStyle(color: Colors.white),
                    decoration: _decoration('Password', Icons.lock_outline).copyWith(
                      suffixIcon: IconButton(
                        onPressed: () => setState(() => _hidePassword = !_hidePassword),
                        icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Text(_error!, style: const TextStyle(color: Colors.redAccent)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton(
                      onPressed: _login,
                      style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: Colors.black),
                      child: _loading
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('LOGIN', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 2)),
                    ),
                  ),
                  const SizedBox(height: 28),
                  const Text('Hanz Dev Official', style: TextStyle(color: Colors.white54)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _decoration(String label, IconData icon) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.white54),
    prefixIcon: Icon(icon, color: const Color(0xFF00D4FF)),
    filled: true,
    fillColor: const Color(0xFF11111F),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: const Color(0xFF00D4FF).withOpacity(.25)),
    ),
  );
}
