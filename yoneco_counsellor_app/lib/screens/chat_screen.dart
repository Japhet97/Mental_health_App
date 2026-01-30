import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';
import '../services/api_service.dart';

class ChatScreen extends StatefulWidget {
  final int sessionId;
  final String issue;

  const ChatScreen({
    super.key,
    required this.sessionId,
    required this.issue,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final CounsellorApiService _api = CounsellorApiService();
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  late WebSocketChannel _channel;
  bool _isLoading = true;
  bool _clientTyping = false;
  bool _showEmojiPicker = false;
  DateTime? _sessionStartTime;
  String _sessionDuration = '00:00';

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    _initializeChat();
    _startTimer();
    _textController.addListener(_onTextChanged);
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _updateDuration();
        _startTimer();
      }
    });
  }

  void _updateDuration() {
    if (_sessionStartTime != null) {
      final duration = DateTime.now().difference(_sessionStartTime!);
      final minutes = duration.inMinutes.toString().padLeft(2, '0');
      final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
      setState(() {
        _sessionDuration = '$minutes:$seconds';
      });
    }
  }

  bool _typingTimer = false;
  void _onTextChanged() {
    if (!_typingTimer && _textController.text.isNotEmpty) {
      _sendTypingIndicator(true);
      _typingTimer = true;
      
      Future.delayed(const Duration(seconds: 2), () {
        _typingTimer = false;
        if (_textController.text.isEmpty) {
          _sendTypingIndicator(false);
        }
      });
    }
  }

  Future<void> _sendTypingIndicator(bool isTyping) async {
    try {
      await _api.sendTypingIndicator(widget.sessionId, 'counsellor', isTyping);
    } catch (e) {
      // Silently fail - typing indicators are not critical
    }
  }

  Future<void> _initializeChat() async {
    try {
      // Load existing messages
      final messages = await _api.getSessionMessages(widget.sessionId);
      setState(() {
        _messages.addAll(messages.map((m) => {
          'sender': m['sender'],
          'content': m['content'],
          'timestamp': m['timestamp'],
          'type': m['type'] ?? 'text',
        }).toList());
        _isLoading = false;
      });

      // Connect to WebSocket
      final wsUrl = _api.getSessionWebSocketUrl(widget.sessionId);
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Listen for incoming messages
      _channel.stream.listen(
        (message) {
          final data = jsonDecode(message);
          
          if (data['type'] == 'message') {
            setState(() {
              _messages.add({
                'sender': data['message']['sender'],
                'content': data['message']['content'],
                'timestamp': data['message']['timestamp'],
                'type': data['message']['type'] ?? 'text',
              });
            });
            _scrollToBottom();
          } else if (data['type'] == 'typing') {
            if (data['sender'] == 'client') {
              setState(() {
                _clientTyping = data['is_typing'];
              });
            }
          } else if (data['type'] == 'session_closed') {
            _showSnackBar('Session has been closed');
            Navigator.pop(context);
          }
        },
        onError: (error) {
          _showSnackBar('Connection error: $error');
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
        },
      );

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error initializing chat: $e');
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  Future<void> _handleSubmitted(String text, {String type = 'text'}) async {
    if (text.trim().isEmpty) return;

    _textController.clear();
    _sendTypingIndicator(false);
    
    try {
      await _api.sendMessage(widget.sessionId, text);
      // Message will be added via WebSocket broadcast
    } catch (e) {
      _showSnackBar('Failed to send message: $e');
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.blue),
              title: const Text('Camera'),
              onTap: () {
                Navigator.pop(context);
                _handleSubmitted('📷 Image shared', type: 'image');
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_file, color: Colors.green),
              title: const Text('Document'),
              onTap: () {
                Navigator.pop(context);
                _handleSubmitted('📄 Document shared', type: 'document');
              },
            ),
            ListTile(
              leading: const Icon(Icons.location_on, color: Colors.red),
              title: const Text('Location'),
              onTap: () {
                Navigator.pop(context);
                _handleSubmitted('📍 Location shared', type: 'location');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        height: 200,
        child: GridView.count(
          crossAxisCount: 8,
          children: [
            '😊', '😂', '❤️', '👍', '👎', '😢', '😮', '😡',
            '🙏', '👏', '🎉', '🔥', '💯', '✨', '⭐', '💪',
            '🤝', '🙌', '👌', '✌️', '🤞', '🤗', '😇', '🥰',
          ].map((emoji) => GestureDetector(
            onTap: () {
              _textController.text += emoji;
              Navigator.pop(context);
            },
            child: Container(
              margin: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[100],
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 24)),
              ),
            ),
          )).toList(),
        ),
      ),
    );
  }

  Future<void> _closeSession() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session'),
        content: const Text('Are you sure you want to end this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('End Session'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _api.closeSession(widget.sessionId);
        if (!mounted) return;
        Navigator.pop(context);
      } catch (e) {
        _showSnackBar('Failed to close session: $e');
      }
    }
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTypingDot(),
            const SizedBox(width: 4),
            _buildTypingDot(delay: 200),
            const SizedBox(width: 4),
            _buildTypingDot(delay: 400),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingDot({int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: (value * 2).clamp(0.3, 1.0),
          child: Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.grey,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
      onEnd: () {
        if (mounted) setState(() {});
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isCounsellor = message['sender'] == 'counsellor';
    final messageType = message['type'] ?? 'text';
    
    return Align(
      alignment: isCounsellor ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
        child: Row(
          mainAxisAlignment: isCounsellor ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isCounsellor) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blue[100],
                child: const Icon(Icons.person, size: 16, color: Colors.blue),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isCounsellor ? const Color(0xFF128C7E) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: isCounsellor ? const Radius.circular(18) : const Radius.circular(4),
                    bottomRight: isCounsellor ? const Radius.circular(4) : const Radius.circular(18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message['content'],
                      style: TextStyle(
                        color: isCounsellor ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message['timestamp']),
                          style: TextStyle(
                            fontSize: 11,
                            color: isCounsellor ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        if (isCounsellor) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.done_all,
                            size: 16,
                            color: Colors.blue[300],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isCounsellor) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF128C7E),
                child: const Icon(Icons.support_agent, size: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatTime(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final dateTime = DateTime.parse(timestamp);
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '';
    }
  }

  Widget _buildInputArea() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _showAttachmentOptions,
              color: Colors.grey[600],
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: () => _handleSubmitted('📷 Image shared', type: 'image'),
              color: Colors.grey[600],
            ),
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: () => _handleSubmitted('📍 Location shared', type: 'location'),
              color: Colors.grey[600],
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.emoji_emotions,
                        color: Colors.grey[600],
                      ),
                      onPressed: _showEmojiOptions,
                    ),
                    Expanded(
                      child: TextField(
                        controller: _textController,
                        onSubmitted: (text) => _handleSubmitted(text),
                        minLines: 1,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                        decoration: const InputDecoration(
                          hintText: "Type your message...",
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE5DDD5),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.person,
                color: const Color(0xFF128C7E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Client',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _clientTyping ? 'typing...' : _sessionDuration,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            tooltip: 'End Session',
            onPressed: _closeSession,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.green[100],
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.green[800], size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Active session for: ${widget.issue}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.green[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Messages
                Expanded(
                  child: _messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet. Start the conversation!',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _messages.length + (_clientTyping ? 1 : 0),
                          itemBuilder: (_, int index) {
                            if (index == _messages.length && _clientTyping) {
                              return _buildTypingIndicator();
                            }
                            return _buildMessageBubble(_messages[index]);
                          },
                        ),
                ),
                
                _buildInputArea(),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _channel.sink.close();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}