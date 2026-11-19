import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDeveloperPage extends StatelessWidget {
  const AboutDeveloperPage({super.key});

  static const _email = 'hanzzcodee@gmail.com';
  static const _support = 'https://saweria.co/hanzreally';

  Future<void> _open(BuildContext context, Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tidak dapat membuka tautan.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFFFF2E63);
    return Scaffold(
      backgroundColor: const Color(0xFF05050A),
      appBar: AppBar(
        title: const Text('TENTANG DEVELOPER'),
        backgroundColor: const Color(0xFF11111F),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 24),
          const Icon(Icons.code_rounded, size: 72, color: accent),
          const SizedBox(height: 18),
          const Center(child: Text('Hanz Dev Official', style: TextStyle(
            color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,
          ))),
          const SizedBox(height: 30),
          ListTile(
            leading: const Icon(Icons.person_outline, color: accent),
            title: const Text('Developer'),
            subtitle: const Text('Hanz Dev Official'),
          ),
          ListTile(
            leading: const Icon(Icons.email_outlined, color: accent),
            title: const Text('Kontak'),
            subtitle: const Text(_email),
            trailing: IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () => Clipboard.setData(const ClipboardData(text: _email)),
            ),
            onTap: () => _open(context, Uri(scheme: 'mailto', path: _email)),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_outline, color: accent),
            title: const Text('Dukung developer'),
            subtitle: const Text(_support),
            onTap: () => _open(context, Uri.parse(_support)),
          ),
        ],
      ),
    );
  }
}
