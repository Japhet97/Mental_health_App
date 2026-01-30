import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final ApiService api = ApiService();
  final TextEditingController _textController = TextEditingController();
  final List<Map<String, String>> _messages = []; // Stores messages: {'sender': 'user/bot', 'text': 'message'}

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final issue = ModalRoute.of(context)!.settings.arguments as String;
    _messages.add({'sender': 'bot', 'text': 'Hello! How can I help you with $issue today?'}); // Initial bot greeting
    api.getChatbotGreeting(issue).then((res) {
      setState(() {
        _messages.add({'sender': 'bot', 'text': res});
      });
    });
  }

  Widget _buildMessageBubble(String message, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isUser ? Theme.of(context).primaryColor : Colors.grey[300],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(15),
            topRight: const Radius.circular(15),
            bottomLeft: isUser ? const Radius.circular(15) : const Radius.circular(0),
            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(15),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  void _handleSubmitted(String text) {
    _textController.clear();
    setState(() {
      _messages.add({'sender': 'user', 'text': text});
    });
    // Simulate bot response (replace with actual API call later)
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _messages.add({'sender': 'bot', 'text': 'I received your message: "$text"'});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("YONECO Chatbot"),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8.0),
              reverse: false, // Set to true for chat-like behavior (new messages at bottom)
              itemCount: _messages.length,
              itemBuilder: (_, int index) {
                final message = _messages[index];
                return _buildMessageBubble(message['text']!, message['sender'] == 'user');
              },
            ),
          ),
          const Divider(height: 1.0),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      onSubmitted: _handleSubmitted,
                      minLines: 1,
                      maxLines: 5, // Allow up to 5 lines before scrolling
                      keyboardType: TextInputType.multiline,
                      decoration: InputDecoration(
                        hintText: "Send a message",
                        border: InputBorder.none, // Remove default border
                        contentPadding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 10.0), // Adjust padding
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: () => _handleSubmitted(_textController.text),
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final issue = ModalRoute.of(context)!.settings.arguments as String;
                  Navigator.pushNamed(
                    context, 
                    '/counsellor',
                    arguments: issue,
                  );
                },
                child: const Text("Talk to Counsellor"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
