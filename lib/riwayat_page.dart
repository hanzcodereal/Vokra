import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// removed unused import: font_awesome_flutter
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'api_config.dart';

class RiwayatPage extends StatefulWidget {
  final String sessionKey;
  final String role;

  const RiwayatPage({super.key, required this.sessionKey, required this.role});

  @override
  State<RiwayatPage> createState() => _RiwayatPageState();
}

class _RiwayatPageState extends State<RiwayatPage> {
  // --- TEMA WARNA UNGU ---
  final Color bgDark = const Color(0xFF0D0221);
  final Color primaryPurple = const Color(0xFF7B1FA2);
  final Color accentPurple = const Color(0xFFEA80FC);
  final Color lightPurple = const Color(0xFFB388FF);
  final Color primaryWhite = Colors.white;
  final Color accentGrey = Colors.grey.shade400;
  final Color cardGlass = Colors.white.withOpacity(0.05);
  final Color borderGlass = Colors.white.withOpacity(0.1);

  List<ActivityModel> activities = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  Future<void> _loadActivities() async {
    try {
      // Request ke endpoint baru yang kita buat
      final response = await http
          .get(Uri.parse('$apiBaseUrl/getMyActivity?key=${widget.sessionKey}'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['valid']) {
          List<dynamic> rawList = data['activities'];

          setState(() {
            activities = rawList.map((item) {
              return ActivityModel(
                type: item['type'] ?? 'system',
                title: item['title'] ?? 'Aktivitas',
                description: item['description'] ?? '-',
                timestamp: _parseTimestamp(item['timestamp']),
              );
            }).toList();
            isLoading = false;
          });
        } else {
          setState(() => isLoading = false);
        }
      } else {
        print("Server Error: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching history: $e");
      setState(() => isLoading = false);
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm').format(date);
  }

  DateTime _parseTimestamp(dynamic ts) {
    if (ts == null) return DateTime.now();
    if (ts is int) return DateTime.fromMillisecondsSinceEpoch(ts);
    if (ts is double) return DateTime.fromMillisecondsSinceEpoch(ts.toInt());
    if (ts is String) {
      final asInt = int.tryParse(ts);
      if (asInt != null) return DateTime.fromMillisecondsSinceEpoch(asInt);
      final parsed = DateTime.tryParse(ts);
      if (parsed != null) return parsed;
    }
    return DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: Text(
          "Riwayat Aktivitas",
          style: TextStyle(
            color: primaryWhite,
            fontFamily: 'Orbitron',
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(color: primaryPurple.withOpacity(0.8), blurRadius: 10),
            ],
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [bgDark, primaryPurple.withOpacity(0.1), bgDark],
          ),
        ),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(accentPurple),
                ),
              )
            : activities.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history_toggle_off, size: 60, color: accentGrey),
                    const SizedBox(height: 16),
                    Text(
                      "Belum ada aktivitas",
                      style: TextStyle(color: accentGrey, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Pastikan server aktif",
                      style: TextStyle(
                        color: accentGrey.withOpacity(0.6),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadActivities,
                color: accentPurple,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: activities.length,
                  itemBuilder: (context, index) {
                    final activity = activities[index];
                    return _buildActivityCard(activity);
                  },
                ),
              ),
      ),
    );
  }

  Widget _buildActivityCard(ActivityModel activity) {
    // determine icon and label based on activity type
    final Map<String, dynamic> meta =
        {
          'login': {
            'icon': Icons.login_rounded,
            'color': Colors.greenAccent,
            'label': 'LOGIN',
          },
          'bug': {
            'icon': Icons.bug_report_outlined,
            'color': Colors.orangeAccent,
            'label': 'ATTACK',
          },
          'create': {
            'icon': Icons.person_add_alt_1_rounded,
            'color': Colors.cyanAccent,
            'label': 'ACCOUNT',
          },
        }[activity.type] ??
        {'icon': Icons.info_outline, 'color': accentGrey, 'label': 'SYSTEM'};

    return GestureDetector(
      onTap: () => _showActivityDetail(activity),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardGlass,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderGlass, width: 1),
          boxShadow: [
            BoxShadow(
              color: primaryPurple.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: (meta['color'] as Color).withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: (meta['color'] as Color).withOpacity(0.3),
                ),
              ),
              child: Icon(
                meta['icon'] as IconData,
                color: meta['color'] as Color,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          activity.title,
                          style: TextStyle(
                            color: primaryWhite,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryPurple.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          meta['label'] as String,
                          style: TextStyle(
                            color: accentPurple,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    activity.description,
                    style: TextStyle(color: accentGrey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: accentGrey.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatDate(activity.timestamp),
                        style: TextStyle(
                          color: accentGrey.withOpacity(0.7),
                          fontSize: 11,
                          fontFamily: 'ShareTechMono',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActivityDetail(ActivityModel activity) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: bgDark,
        title: Text(activity.title, style: TextStyle(color: primaryWhite)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(activity.description, style: TextStyle(color: accentGrey)),
            const SizedBox(height: 12),
            Text(
              _formatDate(activity.timestamp),
              style: TextStyle(
                color: accentGrey.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class ActivityModel {
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;

  ActivityModel({
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
  });
}
