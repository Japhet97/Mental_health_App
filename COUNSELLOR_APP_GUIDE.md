# YONECO Counsellor App - Implementation Guide

## Overview
This guide explains how to build the counsellor-side application that works with the existing client app and API.

## Architecture

### Flow Summary
1. **Client** selects a mental health issue → creates session → waits for counsellor
2. **API** stores session in database with status "pending" → notifies counsellors via WebSocket
3. **Counsellor** sees pending sessions → accepts one → session status changes to "active"
4. **Both** client and counsellor can now chat in real-time via WebSocket

## Counsellor App Structure

```
yoneco_counsellor_app/
├── lib/
│   ├── main.dart
│   ├── models/
│   │   ├── session.dart
│   │   ├── message.dart
│   │   └── counsellor.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   └── websocket_service.dart
│   ├── screens/
│   │   ├── login_screen.dart
│   │   ├── dashboard_screen.dart
│   │   ├── pending_sessions_screen.dart
│   │   ├── active_sessions_screen.dart
│   │   └── chat_screen.dart
│   └── widgets/
│       ├── session_card.dart
│       └── message_bubble.dart
└── pubspec.yaml
```

## Key Features to Implement

### 1. Authentication Screen
- Login with email/password
- Store JWT token for authenticated requests
- Auto-logout on token expiration

### 2. Dashboard
- Shows statistics (active sessions, completed today, etc.)
- Quick access to pending and active sessions
- Real-time notifications for new sessions

### 3. Pending Sessions List
- Display all sessions with status="pending"
- Show: Client name, Issue, Time waiting
- "Accept" button to take the session
- Real-time updates via WebSocket

### 4. Active Sessions List
- Display all sessions assigned to this counsellor
- Show: Client name, Issue, Last message time
- Click to open chat

### 5. Chat Screen (similar to client)
- Real-time messaging via WebSocket
- Load previous messages
- "End Session" button to close the session
- Session notes (optional feature)

## API Endpoints to Use

### Authentication
```
POST /auth/login
Body: { "email": "counsellor@yoneco.org", "password": "password" }
Response: { "access_token": "...", "user": {...} }
```

### Sessions
```
GET  /sessions/pending          # Get pending sessions
GET  /sessions/active           # Get active sessions for this counsellor
GET  /sessions/{session_id}     # Get session details
POST /sessions/{session_id}/accept?counsellor_id=1  # Accept a session
POST /sessions/{session_id}/close  # Close a session
```

### Chat
```
GET  /chat/{session_id}/messages   # Get all messages
POST /chat/{session_id}/send       # Send a message
      Body: { "sender": "counsellor", "content": "..." }
```

### WebSocket
```
ws://API_URL/ws/counselors         # Connect to receive new session notifications
ws://API_URL/ws/session/{id}       # Connect to specific session chat room
```

## Sample Code Snippets

### 1. API Service for Counsellor App

```dart
class CounsellorApiService {
  final String baseUrl = "http://YOUR_API_URL:8000";
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> _headers() {
    return {
      "Content-Type": "application/json",
      if (_token != null) "Authorization": "Bearer $_token",
    };
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setToken(data['access_token']);
      return data;
    } else {
      throw Exception("Login failed");
    }
  }

  Future<List<dynamic>> getPendingSessions() async {
    final response = await http.get(
      Uri.parse("$baseUrl/sessions/pending"),
      headers: _headers(),
    );
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to get pending sessions");
    }
  }

  Future<void> acceptSession(int sessionId, int counsellorId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/sessions/$sessionId/accept?counsellor_id=$counsellorId"),
      headers: _headers(),
    );
    
    if (response.statusCode != 200) {
      throw Exception("Failed to accept session");
    }
  }

  Future<void> closeSession(int sessionId) async {
    final response = await http.post(
      Uri.parse("$baseUrl/sessions/$sessionId/close"),
      headers: _headers(),
    );
    
    if (response.statusCode != 200) {
      throw Exception("Failed to close session");
    }
  }

  String getWebSocketUrl() {
    return "ws://YOUR_API_URL:8000/ws/counselors";
  }

  String getSessionWebSocketUrl(int sessionId) {
    return "ws://YOUR_API_URL:8000/ws/session/$sessionId";
  }
}
```

### 2. WebSocket Service for Notifications

```dart
class WebSocketService {
  WebSocketChannel? _channel;
  final Function(Map<String, dynamic>) onNewSession;

  WebSocketService({required this.onNewSession});

  void connect(String wsUrl) {
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    
    _channel!.stream.listen(
      (message) {
        final data = jsonDecode(message);
        
        if (data['type'] == 'new_session') {
          onNewSession(data['session']);
        }
      },
      onError: (error) {
        print('WebSocket error: $error');
      },
      onDone: () {
        print('WebSocket closed');
      },
    );
  }

  void disconnect() {
    _channel?.sink.close();
  }
}
```

### 3. Pending Sessions Screen

```dart
class PendingSessionsScreen extends StatefulWidget {
  @override
  _PendingSessionsScreenState createState() => _PendingSessionsScreenState();
}

class _PendingSessionsScreenState extends State<PendingSessionsScreen> {
  final CounsellorApiService api = CounsellorApiService();
  List<dynamic> _sessions = [];
  late WebSocketService _wsService;

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _connectWebSocket();
  }

  void _loadSessions() async {
    try {
      final sessions = await api.getPendingSessions();
      setState(() {
        _sessions = sessions;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading sessions: $e')),
      );
    }
  }

  void _connectWebSocket() {
    _wsService = WebSocketService(
      onNewSession: (session) {
        setState(() {
          _sessions.insert(0, session);
        });
        // Optional: Show notification
      },
    );
    _wsService.connect(api.getWebSocketUrl());
  }

  void _acceptSession(int sessionId, int counsellorId) async {
    try {
      await api.acceptSession(sessionId, counsellorId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session accepted!')),
      );
      _loadSessions(); // Refresh list
      
      // Navigate to chat
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(sessionId: sessionId),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error accepting session: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pending Sessions'),
      ),
      body: _sessions.isEmpty
          ? Center(child: Text('No pending sessions'))
          : ListView.builder(
              itemCount: _sessions.length,
              itemBuilder: (context, index) {
                final session = _sessions[index];
                return Card(
                  margin: EdgeInsets.all(8),
                  child: ListTile(
                    leading: Icon(Icons.person, size: 40),
                    title: Text(session['client_name'] ?? 'Anonymous'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Issue: ${session['issue']}'),
                        Text('Waiting since: ${session['created_at']}'),
                      ],
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _acceptSession(
                        session['id'],
                        1, // Replace with actual counsellor ID from auth
                      ),
                      child: Text('Accept'),
                    ),
                  ),
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _wsService.disconnect();
    super.dispose();
  }
}
```

## Database Schema (Already Implemented)

```sql
counsellors
  - id (PK)
  - email (unique)
  - name
  - password_hash
  - is_active
  - created_at

sessions
  - id (PK)
  - client_name
  - issue
  - status (pending/active/closed)
  - counsellor_id (FK to counsellors)
  - created_at

messages
  - id (PK)
  - session_id (FK)
  - sender (client/counsellor)
  - content
  - timestamp
```

## Next Steps

1. **Create Flutter Project**
   ```bash
   flutter create yoneco_counsellor_app
   cd yoneco_counsellor_app
   ```

2. **Add Dependencies** (pubspec.yaml)
   ```yaml
   dependencies:
     http: ^1.5.0
     web_socket_channel: ^3.0.1
     provider: ^6.1.2  # For state management
   ```

3. **Create Counsellor Account** (via API script)
   ```bash
   cd python_api
   python create_counsellor.py
   ```

4. **Implement Screens** (in order)
   - Login Screen
   - Dashboard
   - Pending Sessions
   - Chat Screen
   - Active Sessions

5. **Test Flow**
   - Run API server
   - Run client app and create a session
   - Run counsellor app and accept the session
   - Test real-time chat between both apps

## Additional Features to Consider

- **Push Notifications**: Alert counsellors when new sessions arrive
- **Session Notes**: Allow counsellors to add private notes during sessions
- **Client History**: View previous sessions with the same client
- **Availability Toggle**: Counsellor can mark themselves as available/unavailable
- **Multi-language Support**: Serve clients in different languages
- **Audio/Video Call**: Integrate WebRTC for voice/video support
- **Analytics Dashboard**: Track session metrics, response times, etc.

## Security Considerations

1. All API endpoints (except login) should require JWT authentication
2. Counsellors can only see sessions assigned to them
3. Messages should be encrypted in transit (use HTTPS in production)
4. Implement rate limiting to prevent abuse
5. Add session timeout for inactive chats
6. Validate all user inputs on both client and server

## Deployment

- **API**: Deploy to cloud (AWS, DigitalOcean, Heroku)
- **Database**: Use PostgreSQL in production (SQLite is for development only)
- **Client App**: Build and publish to Google Play / App Store
- **Counsellor App**: Build and distribute to counsellors (can use internal testing)

## Questions or Issues?

Contact the development team or refer to the main API documentation.
