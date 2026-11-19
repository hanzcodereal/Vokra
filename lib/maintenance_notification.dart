import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MaintenanceNotification {
  static const String _maintenanceKey = 'maintenance_mode';
  static const String _notificationDismissedKey = 'maintenance_dismissed';

  static Future<void> setMaintenanceMode(
    bool isEnabled,
    String? message,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_maintenanceKey, isEnabled);
    if (message != null) {
      await prefs.setString('maintenance_message', message);
    }
  }

  static Future<bool> isMaintenanceMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_maintenanceKey) ?? false;
  }

  static Future<String> getMaintenanceMessage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('maintenance_message') ??
        'Server sedang dalam pemeliharaan. Silahkan coba beberapa saat lagi.';
  }

  static Future<void> dismissNotification() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationDismissedKey, true);
  }

  static Future<bool> isNotificationDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_notificationDismissedKey) ?? false;
  }

  static Future<void> resetDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_notificationDismissedKey);
  }
}

class MaintenanceBanner extends StatefulWidget {
  final VoidCallback? onDismiss;

  const MaintenanceBanner({super.key, this.onDismiss});

  @override
  State<MaintenanceBanner> createState() => _MaintenanceBannerState();
}

class _MaintenanceBannerState extends State<MaintenanceBanner> {
  bool _isMaintenanceMode = false;
  bool _isDismissed = false;
  String _maintenanceMessage = '';

  @override
  void initState() {
    super.initState();
    _checkMaintenanceMode();
  }

  Future<void> _checkMaintenanceMode() async {
    final isMaintenance = await MaintenanceNotification.isMaintenanceMode();
    final isDismissed = await MaintenanceNotification.isNotificationDismissed();
    final message = await MaintenanceNotification.getMaintenanceMessage();

    setState(() {
      _isMaintenanceMode = isMaintenance;
      _isDismissed = isDismissed;
      _maintenanceMessage = message;
    });
  }

  void _handleDismiss() {
    setState(() {
      _isDismissed = true;
    });
    MaintenanceNotification.dismissNotification();
    widget.onDismiss?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isMaintenanceMode || _isDismissed) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withOpacity(0.6), width: 2),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.amber.withOpacity(0.15),
            Colors.orange.withOpacity(0.1),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.build, color: Colors.amber, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'MAINTENANCE MODE',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _maintenanceMessage,
                        style: const TextStyle(
                          color: Colors.amberAccent,
                          fontSize: 12,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.amber),
                  onPressed: _handleDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.amber.withOpacity(0.8),
                    Colors.orange.withOpacity(0.4),
                  ],
                ),
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
