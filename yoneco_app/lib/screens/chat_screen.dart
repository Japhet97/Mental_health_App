import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';
import '../services/api_service.dart';
import '../services/language_service.dart';

class ChatScreen extends StatefulWidget {
  final int sessionId;
  final String issue;
  final String clientToken;

  const ChatScreen({
    super.key,
    required this.sessionId,
    required this.issue,
    required this.clientToken,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final ApiService api = ApiService();
  final LanguageService _languageService = LanguageService();
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, dynamic>> _messages = [];
  final List<Map<String, dynamic>> _pendingMessages = [];
  final ScrollController _scrollController = ScrollController();
  
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _counsellorJoined = false;
  bool _isLoading = true;
  bool _counsellorTyping = false;
  bool _showEmojiPicker = false;
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  DateTime? _sessionStartTime;
  String _sessionDuration = '00:00';

  @override
  void initState() {
    super.initState();
    _sessionStartTime = DateTime.now();
    _initializeChat();
    _startTimer();
    _textController.addListener(_onTextChanged);
    _languageService.addListener(_onLanguageChanged);
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
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
      await api.sendTypingIndicator(widget.sessionId, 'client', isTyping);
    } catch (e) {
      // Silently fail - typing indicators are not critical
    }
  }

  Future<void> _initializeChat() async {
    try {
      // Load existing messages
      final messages = await api.getSessionMessages(widget.sessionId);
      setState(() {
        _messages.addAll(messages.map((m) => {
          'sender': m['sender'],
          'content': m['content'],
          'timestamp': m['timestamp'],
          'type': m['type'] ?? 'text',
        }).toList());
        _isLoading = false;
      });

      // Send notification to admin dashboard
      await _notifyAdminDashboard();

      // Connect to WebSocket
      await _connectWebSocket();
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Error initializing chat: $e');
    }
  }

  Future<void> _notifyAdminDashboard() async {
    try {
      // This would typically send a notification to the admin dashboard
      // For now, we'll just log it
      print('Notifying admin dashboard: New session ${widget.sessionId} for issue: ${widget.issue}');
    } catch (e) {
      print('Failed to notify admin dashboard: $e');
    }
  }

  Future<void> _connectWebSocket() async {
    try {
      final wsUrl = api.getWebSocketUrl(widget.sessionId, widget.clientToken);
      print('Connecting to WebSocket: $wsUrl');
      
      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
      
      // Listen for incoming messages
      _channel!.stream.listen(
        (message) {
          _handleWebSocketMessage(message);
          setState(() {
            _isConnected = true;
            _reconnectAttempts = 0;
          });
        },
        onError: (error) {
          print('WebSocket error: $error');
          setState(() {
            _isConnected = false;
          });
          _scheduleReconnect();
        },
        onDone: () {
          print('WebSocket connection closed');
          setState(() {
            _isConnected = false;
          });
          _scheduleReconnect();
        },
      );

      // Send pending messages once connected
      _sendPendingMessages();
      
    } catch (e) {
      print('Failed to connect WebSocket: $e');
      setState(() {
        _isConnected = false;
      });
      _scheduleReconnect();
    }
  }

  void _handleWebSocketMessage(dynamic message) {
    try {
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
        if (data['sender'] == 'counsellor') {
          setState(() {
            _counsellorTyping = data['is_typing'];
          });
        }
      } else if (data['type'] == 'session_accepted') {
        setState(() {
          _counsellorJoined = true;
        });
        _showSnackBar(_languageService.translate('counsellor_joined'));
      } else if (data['type'] == 'session_closed') {
        _showSnackBar(_languageService.translate('session_closed'));
        Navigator.pop(context);
      }
    } catch (e) {
      print('Error handling WebSocket message: $e');
    }
  }

  void _scheduleReconnect() {
    if (_reconnectAttempts < 5) {
      _reconnectTimer?.cancel();
      _reconnectTimer = Timer(Duration(seconds: 2 << _reconnectAttempts), () {
        _reconnectAttempts++;
        _connectWebSocket();
      });
    }
  }

  Future<void> _sendPendingMessages() async {
    for (final message in List.from(_pendingMessages)) {
      try {
        await api.sendMessage(widget.sessionId, 'client', message['content']);
        _pendingMessages.remove(message);
      } catch (e) {
        print('Failed to send pending message: $e');
        break;
      }
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
    
    final messageData = {
      'content': text,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
    };

    try {
      if (_isConnected) {
        await api.sendMessage(widget.sessionId, 'client', text);
        // Message will be added via WebSocket broadcast
      } else {
        // Queue message if not connected
        _pendingMessages.add(messageData);
        _showSnackBar('Message queued - will send when connected');
      }
    } catch (e) {
      // Add to pending messages on failure
      _pendingMessages.add(messageData);
      _showSnackBar('Message queued - will retry');
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      _handleSubmitted('📷 Image: ${image.name}', type: 'image');
    }
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    
    if (result != null) {
      PlatformFile file = result.files.first;
      _handleSubmitted('📄 Document: ${file.name}', type: 'document');
    }
  }

  Future<void> _shareLocation() async {
    try {
      final permission = await Permission.location.request();
      if (permission.isGranted) {
        final position = await Geolocator.getCurrentPosition();
        _handleSubmitted('📍 Location: ${position.latitude}, ${position.longitude}', type: 'location');
      }
    } catch (e) {
      _showSnackBar('Failed to get location');
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
    final isClient = message['sender'] == 'client';
    final messageType = message['type'] ?? 'text';
    
    return Align(
      alignment: isClient ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 16),
        child: Row(
          mainAxisAlignment: isClient ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isClient) ...[
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, size: 16),
              ),
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isClient ? const Color(0xFF128C7E) : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: isClient ? const Radius.circular(18) : const Radius.circular(4),
                    bottomRight: isClient ? const Radius.circular(4) : const Radius.circular(18),
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
                    _buildMessageContent(message['content'], messageType, isClient),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _formatTime(message['timestamp']),
                          style: TextStyle(
                            fontSize: 11,
                            color: isClient ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        if (isClient) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.done_all,
                            size: 16,
                            color: _counsellorJoined ? Colors.blue[300] : Colors.white70,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            if (isClient) ...[
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFF128C7E),
                child: const Icon(Icons.person, size: 16, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(String content, String type, bool isClient) {
    switch (type) {
      case 'image':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.image,
              color: isClient ? Colors.white : Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                content,
                style: TextStyle(
                  color: isClient ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        );
      case 'document':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.description,
              color: isClient ? Colors.white : Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                content,
                style: TextStyle(
                  color: isClient ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        );
      case 'location':
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.location_on,
              color: isClient ? Colors.white : Colors.grey[600],
              size: 16,
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                content,
                style: TextStyle(
                  color: isClient ? Colors.white : Colors.black87,
                ),
              ),
            ),
          ],
        );
      default:
        return Text(
          content,
          style: TextStyle(
            color: isClient ? Colors.white : Colors.black87,
          ),
        );
    }
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.attach_file),
                  onPressed: _pickDocument,
                  color: Colors.grey[600],
                ),
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: _pickImage,
                  color: Colors.grey[600],
                ),
                IconButton(
                  icon: const Icon(Icons.location_on),
                  onPressed: _shareLocation,
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
                            _showEmojiPicker ? Icons.keyboard : Icons.emoji_emotions,
                            color: Colors.grey[600],
                          ),
                          onPressed: () {
                            setState(() {
                              _showEmojiPicker = !_showEmojiPicker;
                            });
                          },
                        ),
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            onSubmitted: (text) => _handleSubmitted(text),
                            minLines: 1,
                            maxLines: 5,
                            keyboardType: TextInputType.multiline,
                            decoration: InputDecoration(
                              hintText: _languageService.translate('type_message'),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
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
          if (_showEmojiPicker)
            SizedBox(
              height: 250,
              child: EmojiPicker(
                onEmojiSelected: (category, emoji) {
                  _textController.text += emoji.emoji;
                },
                config: const Config(
                  height: 256,
                  checkPlatformCompatibility: true,
                  emojiViewConfig: EmojiViewConfig(
                    emojiSizeMax: 28,
                  ),
                ),
              ),
            ),
        ],
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
                Icons.support_agent,
                color: const Color(0xFF128C7E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _counsellorJoined ? 'Counsellor' : 'Waiting for counsellor...',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    _counsellorJoined 
                        ? (_counsellorTyping ? 'typing...' : 'online')
                        : _sessionDuration,
                    style: const TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (!_isConnected)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                if (!_counsellorJoined)
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange[100],
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _languageService.translate('waiting_counsellor'),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                                _languageService.translate('no_messages'),
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
                          itemCount: _messages.length + (_counsellorTyping ? 1 : 0),
                          itemBuilder: (_, int index) {
                            if (index == _messages.length && _counsellorTyping) {
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
    _channel?.sink.close();
    _reconnectTimer?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    _languageService.removeListener(_onLanguageChanged);
    super.dispose();
  }
}