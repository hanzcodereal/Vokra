import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

// Warna - FIXED (const semua)
const Color bgDark = Color(0xFF0D0221);
const Color cardDark = Color(0xFF1E1E2E);
const Color primaryPurple = Color(0xFF7B1FA2);
const Color accentPurple = Color(0xFFEA80FC);
const Color primaryWhite = Colors.white;
const Color textGrey = Colors.grey;

class NotificationChannelPage extends StatefulWidget {
  const NotificationChannelPage({super.key});

  @override
  State<NotificationChannelPage> createState() => _NotificationChannelPageState();
}

class _NotificationChannelPageState extends State<NotificationChannelPage> {
  List<TelegramMessage> messages = [];
  bool isLoading = true;
  String? errorMessage;
  Timer? autoRefreshTimer;
  String botToken = '8793387802:AAHHoz_SkbS-odN7mW7GKd0bMLXJ9y_iAts';
  bool isTokenSet = false;
  final TextEditingController tokenController = TextEditingController();
  
  final String channelUsername = 'testimonixyanz';

  @override
  void initState() {
    super.initState();
    if (botToken.isNotEmpty) {
      isTokenSet = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchTelegramMessages();
        _startAutoRefresh();
      });
    }
  }

  void _startAutoRefresh() {
    autoRefreshTimer?.cancel();
    autoRefreshTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (isTokenSet && mounted) {
        fetchTelegramMessages();
      }
    });
  }

  void _saveToken() {
    setState(() {
      botToken = tokenController.text.trim();
      if (botToken.isNotEmpty) {
        isTokenSet = true;
        fetchTelegramMessages();
        _startAutoRefresh();
      }
    });
  }

  void _resetToken() {
    setState(() {
      botToken = '';
      isTokenSet = false;
      messages = [];
      tokenController.clear();
      autoRefreshTimer?.cancel();
    });
  }

  Future<void> fetchTelegramMessages() async {
    if (!isTokenSet || botToken.isEmpty) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.telegram.org/bot$botToken/getUpdates'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        if (data['ok'] == true) {
          List<dynamic> updates = data['result'];
          List<TelegramMessage> tempMessages = [];
          
          for (var update in updates) {
            if (update.containsKey('message')) {
              var message = update['message'];
              var chat = message['chat'];
              
              String chatUsername = chat['username'] ?? '';
              String chatTitle = chat['title'] ?? '';
              int chatId = chat['id'];
              
              bool isTargetChannel = 
                  chatUsername.toLowerCase() == channelUsername.toLowerCase() ||
                  chatTitle.toLowerCase().contains(channelUsername.toLowerCase());
              
              if (isTargetChannel) {
                String messageText = message['text'] ?? 
                                   message['caption'] ?? 
                                   '[Media/Unsupported message type]';
                
                String sender = message['from']['first_name'] ?? 
                               message['from']['username'] ?? 
                               'Channel';
                
                tempMessages.add(TelegramMessage(
                  text: messageText,
                  date: DateTime.fromMillisecondsSinceEpoch(message['date'] * 1000),
                  messageId: message['message_id'],
                  sender: sender,
                  chatId: chatId,
                  chatTitle: chatTitle.isNotEmpty ? chatTitle : '@$chatUsername',
                ));
              }
            }
          }
          
          tempMessages.sort((a, b) => a.date.compareTo(b.date));
          
          setState(() {
            messages = tempMessages;
            isLoading = false;
            if (messages.isEmpty) {
              errorMessage = 'No messages found in @$channelUsername. Send a message to the channel first.';
            }
          });
        } else {
          setState(() {
            errorMessage = 'API Error: ${data['description']}';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'HTTP ${response.statusCode}: Failed to connect';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Connection failed: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgDark,
      appBar: AppBar(
        title: const Text('𝐈𝐓 𝐗𝐍𝐗𝐒𝐃 Monitor'),
        backgroundColor: cardDark,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: primaryPurple),
        ),
        actions: [
          if (isTokenSet)
            IconButton(
              icon: const Icon(Icons.settings),
              color: primaryPurple,
              onPressed: _showSettingsDialog,
            ),
          if (isTokenSet)
            IconButton(
              icon: const Icon(Icons.refresh),
              color: accentPurple,
              onPressed: fetchTelegramMessages,
            ),
        ],
      ),
      body: !isTokenSet 
          ? _buildTokenSetup()
          : Column(
              children: [
                _buildChannelHeader(),
                Expanded(
                  child: isLoading 
                      ? _buildLoader()
                      : errorMessage != null && messages.isEmpty
                          ? _buildErrorWidget()
                          : _buildMessageList(),
                ),
              ],
            ),
    );
  }

  Widget _buildTokenSetup() {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.telegram, size: 80, color: accentPurple),
            const SizedBox(height: 24),
            Text(
              'TZY Bot Setup',
              style: TextStyle(
                color: primaryPurple,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: primaryPurple),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'How to get Bot Token:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildStep('1', 'Open Telegram and search @BotFather'),
                  _buildStep('2', 'Send /newbot command'),
                  _buildStep('3', 'Name your bot (e.g., ChannelMonitorBot)'),
                  _buildStep('4', 'Username must end with "bot"'),
                  _buildStep('5', 'Copy the token they send you'),
                  _buildStep('6', 'Add bot as ADMIN to @$channelUsername'),
                  const SizedBox(height: 16),
                  TextField(
                    controller: tokenController,
                    style: const TextStyle(color: primaryWhite),
                    decoration: InputDecoration(
                      hintText: 'Paste your bot token here',
                      hintStyle: TextStyle(color: textGrey),
                      prefixIcon: Icon(Icons.vpn_key, color: accentPurple),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryPurple),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: primaryPurple.withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: accentPurple, width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _saveToken,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('CONNECT TO CHANNEL'),
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

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: primaryPurple,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: TextStyle(color: textGrey, fontSize: 12))),
        ],
      ),
    );
  }

  Widget _buildChannelHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardDark,
        border: Border(bottom: BorderSide(color: primaryPurple.withOpacity(0.3))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [primaryPurple, accentPurple],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.telegram, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '@$channelUsername',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${messages.length} messages captured',
                  style: TextStyle(color: textGrey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isTokenSet ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isTokenSet ? Colors.green : Colors.red,
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isTokenSet ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isTokenSet ? 'CONNECTED' : 'DISCONNECTED',
                  style: TextStyle(
                    color: isTokenSet ? Colors.green : Colors.red,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final msg = messages[index];
        return _buildMessageCard(msg);
      },
    );
  }

  Widget _buildMessageCard(TelegramMessage msg) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardDark,
        borderRadius: BorderRadius.circular(12),
        border: Border(
          left: BorderSide(color: primaryPurple, width: 4),
          top: BorderSide(color: cardDark, width: 1),
          right: BorderSide(color: cardDark, width: 1),
          bottom: BorderSide(color: cardDark, width: 1),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onLongPress: () => _showMessageDetails(msg),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: primaryPurple.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.person, color: accentPurple, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            msg.sender,
                            style: TextStyle(
                              color: accentPurple,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            msg.chatTitle,
                            style: TextStyle(color: textGrey, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _formatTime(msg.date),
                          style: TextStyle(color: textGrey, fontSize: 10),
                        ),
                        Text(
                          'ID: ${msg.messageId}',
                          style: TextStyle(color: primaryPurple, fontSize: 9),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: bgDark,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(color: primaryWhite, fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showMessageDetails(TelegramMessage msg) {
    showModalBottomSheet(
      context: context,
      backgroundColor: cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Message Details', style: TextStyle(color: primaryPurple, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildDetailRow('Chat', msg.chatTitle),
            _buildDetailRow('Sender', msg.sender),
            _buildDetailRow('Message ID', '#${msg.messageId}'),
            _buildDetailRow('Date', _formatFullDate(msg.date)),
            const SizedBox(height: 12),
            const Text('Content:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: bgDark,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SelectableText(msg.text, style: TextStyle(color: primaryWhite)),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text('$label: ', style: TextStyle(color: accentPurple, fontWeight: FontWeight.bold)),
          Expanded(child: Text(value, style: TextStyle(color: textGrey))),
        ],
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text('Fetching from @$channelUsername...', style: TextStyle(color: textGrey)),
          const SizedBox(height: 8),
          Text('This may take a few seconds', style: TextStyle(color: textGrey, fontSize: 10)),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 64),
            const SizedBox(height: 16),
            Text('TZY - Unable to Fetch', style: TextStyle(color: primaryPurple, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                errorMessage ?? 'Unknown error occurred',
                style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: fetchTelegramMessages,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(backgroundColor: primaryPurple),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: _showSettingsDialog,
                  icon: const Icon(Icons.settings, size: 18),
                  label: const Text('Settings'),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: primaryPurple),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardDark,
        title: Text('Bot Settings', style: TextStyle(color: primaryPurple)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: tokenController,
              style: const TextStyle(color: primaryWhite),
              decoration: InputDecoration(
                hintText: 'Enter new bot token',
                hintStyle: TextStyle(color: textGrey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text('Current status: ${isTokenSet ? "Connected" : "Not connected"}', 
                 style: TextStyle(color: textGrey)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetToken();
            },
            child: Text('Reset', style: TextStyle(color: Colors.red)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveToken();
            },
            child: Text('Update', style: TextStyle(color: accentPurple)),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inDays > 7) {
      return '${(diff.inDays / 7).floor()}w ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}:${date.second.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    autoRefreshTimer?.cancel();
    tokenController.dispose();
    super.dispose();
  }
}

class TelegramMessage {
  final String text;
  final DateTime date;
  final int messageId;
  final String sender;
  final int chatId;
  final String chatTitle;

  TelegramMessage({
    required this.text,
    required this.date,
    required this.messageId,
    required this.sender,
    required this.chatId,
    required this.chatTitle,
  });
}