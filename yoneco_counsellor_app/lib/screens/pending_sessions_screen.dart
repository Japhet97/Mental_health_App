import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../services/notification_service.dart';
import 'chat_screen.dart';

class PendingSessionsScreen extends StatefulWidget {
  const PendingSessionsScreen({super.key});

  @override
  State<PendingSessionsScreen> createState() => _PendingSessionsScreenState();
}

class _PendingSessionsScreenState extends State<PendingSessionsScreen> {
  final CounsellorApiService _api = CounsellorApiService();
  final NotificationService _notificationService = NotificationService();
  List<dynamic> _sessions = [];
  bool _isLoading = true;
  WebSocketChannel? _channel;
  bool _hasPlayedInitialSound = false;

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _connectWebSocket();
  }

  Future<void> _loadSessions() async {
    try {
      final sessions = await _api.getPendingSessions();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading sessions: $e')),
        );
      }
    }
  }

  void _connectWebSocket() {
    try {
      final wsUrl = _api.getWebSocketUrl();
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        (message) {
          debugPrint('WebSocket message received: $message');
          final data = jsonDecode(message);
          
          if (data['type'] == 'heartbeat') {
            // Ignore heartbeat messages
            return;
          }
          
          if (data['type'] == 'new_session') {
            // New session notification - INSTANT
            if (mounted) {
              // Play notification sound IMMEDIATELY
              _notificationService.playNotificationSound();
              
              // Reload sessions automatically
              _loadSessions();
              
              // Show notification
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.notifications_active, color: Colors.white),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'New Client Waiting!',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              data['session']?['client_name'] ?? 'Anonymous Client',
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: Colors.orange,
                  duration: const Duration(seconds: 5),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: 'VIEW',
                    textColor: Colors.white,
                    onPressed: () {
                      // List will auto-update, just dismiss
                    },
                  ),
                ),
              );
            }
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          // Attempt reconnect on error
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _connectWebSocket();
          });
        },
        onDone: () {
          debugPrint('WebSocket closed, attempting to reconnect...');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _connectWebSocket();
          });
        },
      );
      
      debugPrint('WebSocket connected: $wsUrl');
    } catch (e) {
      debugPrint('Failed to connect WebSocket: $e');
      // Retry connection after delay
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) _connectWebSocket();
      });
    }
  }

  Future<void> _acceptSession(int sessionId, String issue) async {
    try {
      await _api.acceptSession(sessionId);
      
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Session accepted!')),
      );

      // Navigate to chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            sessionId: sessionId,
            issue: issue,
          ),
        ),
      ).then((_) => _loadSessions()); // Refresh when returning

    } catch (e) {
      if (!mounted) return;
      
      // Check if token expired
      if (e.toString().contains('Session expired') || e.toString().contains('Please login again')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session expired. Please login again.'),
            backgroundColor: Colors.red,
          ),
        );
        // Navigate back to login
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        return;
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept session: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTimestamp(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(dt);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours}h ago';
      } else {
        return DateFormat('MMM d, HH:mm').format(dt);
      }
    } catch (e) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Sessions'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSessions,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _sessions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.inbox,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No pending sessions',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'New sessions will appear here',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadSessions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: _sessions.length,
                    itemBuilder: (context, index) {
                      final session = _sessions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 8,
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.orange,
                            child: Text(
                              (session['client_name'] ?? 'A')[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            session['client_name'] ?? 'Anonymous Client',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.psychology, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      session['issue'] ?? 'No issue specified',
                                      style: const TextStyle(fontStyle: FontStyle.italic),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (session['language'] != null && session['language'] != 'en')
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.language, size: 14, color: Colors.blue),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Language: ${session['language'] == 'ny' ? 'Chichewa' : session['language']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Row(
                                children: [
                                  const Icon(Icons.access_time, size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Waiting: ${_formatTimestamp(session['created_at'])}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: () => _acceptSession(
                              session['id'],
                              session['issue'] ?? 'General Support',
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Accept'),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }
}
