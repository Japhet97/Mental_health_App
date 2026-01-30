import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/language_service.dart';
import 'chat_screen.dart';

class CounsellorScreen extends StatefulWidget {
  const CounsellorScreen({super.key});

  @override
  State<CounsellorScreen> createState() => _CounsellorScreenState();
}

class _CounsellorScreenState extends State<CounsellorScreen> {
  final ApiService api = ApiService();
  final LanguageService _languageService = LanguageService();
  final TextEditingController _nameController = TextEditingController();
  bool _isCreatingSession = false;
  String? _issue;

  @override
  void initState() {
    super.initState();
    _languageService.addListener(_onLanguageChanged);
  }

  @override
  void dispose() {
    _languageService.removeListener(_onLanguageChanged);
    _nameController.dispose();
    super.dispose();
  }

  void _onLanguageChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get the issue from previous screen if available
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is String) {
      _issue = args;
    }
  }

  Future<void> _startLiveChat() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_languageService.translate('please_enter_name'))),
      );
      return;
    }

    setState(() {
      _isCreatingSession = true;
    });

    try {
      // Create a new session with language information
      final session = await api.createSession(
        clientName: _nameController.text.trim(),
        issue: _issue ?? _languageService.translate('other'),
        language: _languageService.currentLanguage,
      );

      if (!mounted) return;

      // Send immediate notification to admin dashboard
      await _notifyAdminDashboard(session);

      // Navigate to chat screen with token
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            sessionId: session['id'],
            issue: session['issue'] ?? _languageService.translate('other'),
            clientToken: session['client_token'],  // Pass the token
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      setState(() {
        _isCreatingSession = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_languageService.translate('failed_to_start_chat')}: $e')),
      );
    }
  }

  Future<void> _notifyAdminDashboard(Map<String, dynamic> session) async {
    try {
      // Send notification to admin dashboard about new session
      await api.notifyAdminDashboard({
        'type': 'new_session',
        'session_id': session['id'],
        'client_name': _nameController.text.trim(),
        'issue': _issue ?? _languageService.translate('other'),
        'language': _languageService.currentLanguage,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Failed to notify admin dashboard: $e');
      // Don't fail the session creation if notification fails
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_languageService.translate('counsellor_connect')),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.people_alt,
              size: 80,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 30),
            Text(
              _languageService.translate('connect_counsellor'),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (_issue != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${_languageService.translate('issue_label')}: $_issue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 30),
            Text(
              _languageService.translate('counsellor_will_join'),
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: _languageService.translate('your_name'),
                hintText: _languageService.translate('enter_name'),
                prefixIcon: const Icon(Icons.person),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              textInputAction: TextInputAction.done,
              onSubmitted: (_) => _startLiveChat(),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isCreatingSession ? null : _startLiveChat,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: _isCreatingSession
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Text(
                        _languageService.translate('start_live_chat'),
                        style: const TextStyle(fontSize: 18),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _languageService.translate('support_available'),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
