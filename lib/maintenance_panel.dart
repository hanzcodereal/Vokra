import 'package:flutter/material.dart';
import 'maintenance_notification.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaintenancePanel extends StatefulWidget {
  const MaintenancePanel({super.key});

  @override
  State<MaintenancePanel> createState() => _MaintenancePanelState();
}

class _MaintenancePanelState extends State<MaintenancePanel> {
  bool _isMaintenanceEnabled = false;
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _serverKeyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMaintenanceStatus();
  }

  Future<void> _loadMaintenanceStatus() async {
    final status = await MaintenanceNotification.isMaintenanceMode();
    final message = await MaintenanceNotification.getMaintenanceMessage();
    final prefs = await SharedPreferences.getInstance();
    final key = prefs.getString('fcm_server_key') ?? '';
    setState(() {
      _isMaintenanceEnabled = status;
      _messageController.text = message;
      _serverKeyController.text = key;
    });
  }

  Future<void> _toggleMaintenance(bool value) async {
    await MaintenanceNotification.setMaintenanceMode(
      value,
      _messageController.text,
    );
    await MaintenanceNotification.resetDismissed();
    setState(() {
      _isMaintenanceEnabled = value;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Mode maintenance DIAKTIFKAN'
                : 'Mode maintenance DINONAKTIFKAN',
          ),
          backgroundColor: value ? Colors.orange : Colors.green,
        ),
      );
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF141414),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Developer Panel - Maintenance Control',
              style: TextStyle(
                color: Colors.lightBlue,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            // Toggle Maintenance Mode
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.lightBlue.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Maintenance Mode',
                        style: TextStyle(
                          color: Colors.lightBlue,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Switch(
                        value: _isMaintenanceEnabled,
                        onChanged: _toggleMaintenance,
                        activeColor: Colors.amber,
                        activeTrackColor: Colors.amber.withOpacity(0.3),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Maintenance Message:',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Colors.lightBlue),
                    decoration: InputDecoration(
                      hintText: 'Masukkan pesan maintenance...',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.lightBlue.withOpacity(0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.lightBlue.withOpacity(0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.lightBlue),
                      ),
                    ),
                    maxLines: 3,
                    enabled: _isMaintenanceEnabled,
                    onChanged: (value) async {
                      if (_isMaintenanceEnabled) {
                        await MaintenanceNotification.setMaintenanceMode(
                          true,
                          value,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _isMaintenanceEnabled
                        ? () async {
                            await MaintenanceNotification.setMaintenanceMode(
                              true,
                              _messageController.text,
                            );
                            await MaintenanceNotification.resetDismissed();
                            // Broadcast via FCM if server key configured
                            await NotificationService.broadcastMaintenance(
                              _messageController.text,
                            );
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Notifikasi di-reset ke semua user',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            }
                          }
                        : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reset Notification for All Users'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // FCM Server Key (optional) - store locally so app can broadcast
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1F1F1F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.lightBlue.withOpacity(0.2)),
              ),
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Optional: FCM Server Key',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _serverKeyController,
                    style: const TextStyle(color: Colors.lightBlue),
                    decoration: InputDecoration(
                      hintText: 'Masukkan server key FCM (optional)',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: const Color(0xFF2A2A2A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: Colors.lightBlue.withOpacity(0.3),
                        ),
                      ),
                    ),
                    maxLines: 1,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setString(
                            'fcm_server_key',
                            _serverKeyController.text.trim(),
                          );
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('FCM server key disimpan'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        },
                        child: const Text('Simpan Key'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.lightBlue,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.remove('fcm_server_key');
                          _serverKeyController.clear();
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('FCM server key dihapus'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                        child: const Text('Hapus Key'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withOpacity(0.3)),
              ),
              padding: const EdgeInsets.all(12),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Info:',
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Ketika Maintenance Mode diaktifkan, notifikasi akan muncul di semua perangkat.\n• User dapat dismiss notifikasi, tapi akan muncul kembali jika halaman di-refresh.\n• Gunakan "Reset Notification" untuk menampilkan notifikasi kembali ke semua user yang sudah dismiss.',
                    style: TextStyle(
                      color: Colors.amberAccent,
                      fontSize: 12,
                      height: 1.6,
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
}
